import 'dart:async';
import 'dart:convert';
import 'dart:io';

const codeAutomationPromptVersion = 'code-sync-v1';
const defaultGeminiModel = 'gemini-3.1-flash-lite';

typedef JsonMap = Map<String, Object?>;
typedef RetrySleep = Future<void> Function(Duration delay);

const _connectionTimeout = Duration(seconds: 15);
const _githubRequestTimeout = Duration(seconds: 30);
const _geminiRequestTimeout = Duration(seconds: 120);
const _maxRequestAttempts = 3;
const _retryBaseDelay = Duration(seconds: 2);
const _bipStatusTags = {'Draft', 'Complete', 'Deployed', 'Closed'};

Future<void> main(List<String> args) async {
  SyncCodeContentOptions? options;
  HttpCodeSourceClient? http;
  try {
    options = SyncCodeContentOptions.parse(args, Platform.environment);
    http = HttpCodeSourceClient(
      githubToken: Platform.environment['GITHUB_TOKEN'],
    );
    final draftClient = options.skipAi
        ? NullCodeContentDraftClient()
        : GeminiCodeContentDraftClient.fromEnvironment(Platform.environment);
    final sync = CodeContentSync(
      options: options,
      sourceClient: http,
      draftClient: draftClient,
      now: DateTime.now().toUtc(),
    );

    final report = await sync.run();
    stdout.writeln(report.toConsoleString());
    if (options.reportPath != null) {
      final reportFile = File(options.reportPath!);
      reportFile.parent.createSync(recursive: true);
      reportFile.writeAsStringSync(report.toMarkdown());
    }
  } on Object catch (error, stackTrace) {
    stderr.writeln('sync_code_content failed: $error');
    if (options?.verbose ?? false) {
      stderr.writeln(stackTrace);
    }
    exitCode = 1;
  } finally {
    http?.close();
  }
}

final class SyncCodeContentOptions {
  const SyncCodeContentOptions({
    required this.languages,
    required this.maxReleases,
    required this.skipAi,
    required this.dryRun,
    required this.verbose,
    required this.reportPath,
  });

  final List<String> languages;
  final int maxReleases;
  final bool skipAi;
  final bool dryRun;
  final bool verbose;
  final String? reportPath;

  static SyncCodeContentOptions parse(
    List<String> args,
    Map<String, String> environment,
  ) {
    var languages = const ['en', 'it'];
    var maxReleases = 12;
    var skipAi = environment['GEMINI_API_KEY'] == null;
    var dryRun = false;
    var verbose = false;
    String? reportPath;

    for (var i = 0; i < args.length; i += 1) {
      final arg = args[i];
      switch (arg) {
        case '--languages':
          i += 1;
          if (i >= args.length) {
            throw const FormatException('--languages requires a value.');
          }
          languages = args[i]
              .split(',')
              .map((language) => language.trim())
              .where((language) => language.isNotEmpty)
              .toList(growable: false);
        case '--max-releases':
          i += 1;
          if (i >= args.length) {
            throw const FormatException('--max-releases requires a value.');
          }
          maxReleases = int.parse(args[i]);
        case '--skip-ai':
          skipAi = true;
        case '--require-ai':
          skipAi = false;
        case '--dry-run':
          dryRun = true;
        case '--verbose':
          verbose = true;
        case '--report':
          i += 1;
          if (i >= args.length) {
            throw const FormatException('--report requires a value.');
          }
          reportPath = args[i];
        default:
          throw FormatException('Unsupported argument: $arg');
      }
    }

    if (languages.isEmpty) {
      throw const FormatException('At least one language is required.');
    }
    if (maxReleases < 1) {
      throw const FormatException('--max-releases must be positive.');
    }
    if (!skipAi && (environment['GEMINI_API_KEY'] ?? '').isEmpty) {
      throw const FormatException(
        '--require-ai was set but GEMINI_API_KEY is missing.',
      );
    }

    return SyncCodeContentOptions(
      languages: languages,
      maxReleases: maxReleases,
      skipAi: skipAi,
      dryRun: dryRun,
      verbose: verbose,
      reportPath: reportPath,
    );
  }
}

final class CodeContentSync {
  CodeContentSync({
    required this.options,
    required this.sourceClient,
    required this.draftClient,
    required this.now,
    this.bundleDirectory = 'assets/content',
  });

  final SyncCodeContentOptions options;
  final CodeSourceClient sourceClient;
  final CodeContentDraftClient draftClient;
  final DateTime now;
  final String bundleDirectory;

  Future<CodeSyncReport> run() async {
    final bips = await sourceClient.fetchBips();
    final releases = await sourceClient.fetchBitcoinCoreReleases(
      limit: options.maxReleases,
    );
    final languageReports = <LanguageSyncReport>[];

    for (final language in options.languages) {
      final bundlePath = '$bundleDirectory/seed_bundle_$language.json';
      final bundleFile = File(bundlePath);
      if (!bundleFile.existsSync()) {
        throw StateError('Missing bundle file: $bundlePath');
      }

      final decoded = jsonDecode(bundleFile.readAsStringSync());
      if (decoded is! JsonMap) {
        throw StateError('Bundle root must be an object: $bundlePath');
      }
      final bundle = JsonMap.from(decoded);
      final report = await _updateBundle(
        bundle: bundle,
        language: language,
        sourceBips: bips,
        sourceReleases: releases,
      );
      languageReports.add(report);

      if (!options.dryRun && report.changed) {
        final normalized = const JsonEncoder.withIndent('  ').convert(bundle);
        bundleFile.writeAsStringSync('$normalized\n');
      }
    }

    return CodeSyncReport(
      generatedAt: now,
      bipsFetched: bips.length,
      releasesFetched: releases.length,
      languages: languageReports,
    );
  }

  Future<LanguageSyncReport> _updateBundle({
    required JsonMap bundle,
    required String language,
    required List<SourceBip> sourceBips,
    required List<SourceRelease> sourceReleases,
  }) async {
    final existingBips = _indexedById(bundle['bips']);
    final existingReleases = _indexedById(bundle['changelogs']);
    final changes = <String>[];
    final warnings = <String>[];

    final updatedBips = <JsonMap>[];
    for (final source in sourceBips) {
      final id = 'code.bip.${source.number}';
      final existing = existingBips[id];
      if (bipStatusOrNull(source.status) == null) {
        final action = existing == null ? 'skipped' : 'kept unchanged';
        final warning =
            'BIP ${source.number}: unknown status "${source.status}", '
            'record $action.';
        warnings.add(warning);
        stderr.writeln('warning: $warning');
        if (existing != null) updatedBips.add(existing);
        continue;
      }
      final record = await _buildBipRecord(
        source: source,
        existing: existing,
        language: language,
        warnings: warnings,
      );
      final unchanged = _isUnchanged(existing, record);
      if (unchanged) {
        record['updatedAt'] = existing!['updatedAt'];
      } else {
        changes.add('BIP ${source.number}: ${source.title}');
      }
      updatedBips.add(record);
    }
    updatedBips.sort(
      (a, b) => (a['number'] as int).compareTo(b['number'] as int),
    );

    final updatedReleases = <JsonMap>[];
    for (final source in sourceReleases) {
      final id = 'release.bitcoin-core.${source.version}';
      final existing = existingReleases[id];
      final record = await _buildReleaseRecord(
        source: source,
        existing: existing,
        language: language,
        warnings: warnings,
      );
      final unchanged = _isUnchanged(existing, record);
      if (unchanged) {
        record['updatedAt'] = existing!['updatedAt'];
      } else {
        changes.add('Bitcoin Core ${source.version}');
      }
      updatedReleases.add(record);
    }
    updatedReleases.sort((a, b) {
      final aVersion = VersionParts.parse(a['version'] as String);
      final bVersion = VersionParts.parse(b['version'] as String);
      return bVersion.compareTo(aVersion);
    });

    final changed =
        !_jsonDeepEquals(bundle['bips'], updatedBips) ||
        !_jsonDeepEquals(bundle['changelogs'], updatedReleases);
    return _finishLanguage(
      bundle: bundle,
      language: language,
      changed: changed,
      changes: changes,
      warnings: warnings,
      updatedBips: updatedBips,
      updatedReleases: updatedReleases,
    );
  }

  LanguageSyncReport _finishLanguage({
    required JsonMap bundle,
    required String language,
    required bool changed,
    required List<String> changes,
    required List<String> warnings,
    required List<JsonMap> updatedBips,
    required List<JsonMap> updatedReleases,
  }) {
    bundle['bips'] = updatedBips;
    bundle['changelogs'] = updatedReleases;
    if (changed) {
      bundle['version'] = _bundleVersion(now);
      bundle['generatedAt'] = now.toIso8601String();
    }

    return LanguageSyncReport(
      language: language,
      changed: changed,
      changedItems: changes,
      warnings: warnings,
      bipCount: updatedBips.length,
      releaseCount: updatedReleases.length,
    );
  }

  Future<JsonMap> _buildBipRecord({
    required SourceBip source,
    required JsonMap? existing,
    required String language,
    required List<String> warnings,
  }) async {
    final existingAutomation = _automation(existing);
    final upstreamChanged =
        existing != null && existingAutomation['upstreamSha'] != source.sha;
    final shouldGenerateDraft =
        existing == null ||
        (_isAiManaged(existing) && upstreamChanged) ||
        _stillHasPlaceholder(
          existing,
          'summaryMarkdown',
          GeneratedDraft.bipFallback(source, language).summaryMarkdown,
        );
    final draftResult = shouldGenerateDraft
        ? await _requestDraft(
            () => draftClient.generateBipDraft(source, language),
            label: 'BIP ${source.number} ($language)',
            outcome: existing == null
                ? 'placeholder text used'
                : 'current text kept',
            warnings: warnings,
          )
        : null;
    final draft = draftResult?.draft;
    final upstreamSha = _upstreamShaToStore(
      source.sha,
      existingAutomation: existingAutomation,
      deferred: _deferUpstream(
        existing: existing,
        shouldGenerateDraft: shouldGenerateDraft,
        draftResult: draftResult,
      ),
    );
    final fallback = GeneratedDraft.bipFallback(source, language);
    final textDraft = draft ?? fallback;
    final statusHistory = _statusHistoryFor(
      existing: existing,
      newStatus: source.status,
      sourceLabel: 'bitcoin/bips',
    );
    final currentStatusTag = _titleCase(source.status);

    return {
      'id': 'code.bip.${source.number}',
      'number': source.number,
      'language': language,
      'title': source.title,
      'summary': _preserveText(
        existing,
        'summary',
        textDraft.summary,
        allowOverwrite: draft != null,
      ),
      'status': source.status,
      'category': source.category,
      'authors': source.authors,
      'createdAt': source.assignedAt ?? '1970-01-01',
      'summaryMarkdown': _preserveText(
        existing,
        'summaryMarkdown',
        textDraft.summaryMarkdown,
        allowOverwrite: draft != null,
      ),
      'impactMarkdown': _preserveText(
        existing,
        'impactMarkdown',
        textDraft.impactMarkdown,
        allowOverwrite: draft != null,
      ),
      'officialUrl': source.officialUrl,
      'tags': _mergeTags(
        existing,
        ['BIP', _titleCase(source.category), currentStatusTag],
        removeTags: _bipStatusTags
            .where((tag) => tag != currentStatusTag)
            .toSet(),
      ),
      'sources': _preserveList(existing, 'sources', [
        {
          'title': 'BIP ${source.number}',
          'url': source.officialUrl,
          'author': 'Bitcoin BIPs',
        },
      ]),
      'related': _preserveList(existing, 'related', const []),
      'statusHistory': statusHistory,
      if (existing?['reviewedAt'] != null)
        'reviewedAt': existing!['reviewedAt'],
      'updatedAt': now.toIso8601String(),
      'automation': _recordAutomation(
        existing: existing,
        existingAutomation: existingAutomation,
        draft: draft,
        upstreamSha: upstreamSha,
        upstreamUrl: source.officialUrl,
      ),
    };
  }

  Future<JsonMap> _buildReleaseRecord({
    required SourceRelease source,
    required JsonMap? existing,
    required String language,
    required List<String> warnings,
  }) async {
    final existingAutomation = _automation(existing);
    final upstreamChanged =
        existing != null && existingAutomation['upstreamSha'] != source.sha;
    final shouldGenerateDraft =
        existing == null ||
        (_isAiManaged(existing) && upstreamChanged) ||
        _stillHasPlaceholder(
          existing,
          'userImpactMarkdown',
          GeneratedDraft.releaseFallback(source, language).userImpactMarkdown,
        );
    final draftResult = shouldGenerateDraft
        ? await _requestDraft(
            () => draftClient.generateReleaseDraft(source, language),
            label: 'Bitcoin Core ${source.version} ($language)',
            outcome: existing == null
                ? 'placeholder text used'
                : 'current text kept',
            warnings: warnings,
          )
        : null;
    final draft = draftResult?.draft;
    final upstreamSha = _upstreamShaToStore(
      source.sha,
      existingAutomation: existingAutomation,
      deferred: _deferUpstream(
        existing: existing,
        shouldGenerateDraft: shouldGenerateDraft,
        draftResult: draftResult,
      ),
    );
    final fallback = GeneratedDraft.releaseFallback(source, language);
    final textDraft = draft ?? fallback;
    final existingReleasedAt = existing?['releasedAt'];

    return {
      'id': 'release.bitcoin-core.${source.version}',
      'slug': 'bitcoin-core-${source.version.replaceAll('.', '-')}',
      'language': language,
      'project': 'bitcoin-core',
      'version': source.version,
      'title': 'Bitcoin Core ${source.version}',
      'summary': _preserveText(
        existing,
        'summary',
        textDraft.summary,
        allowOverwrite: draft != null,
      ),
      'releasedAt':
          source.releasedAt ??
          (existingReleasedAt is String
              ? existingReleasedAt
              : now.toIso8601String().split('T').first),
      'importance': _preserveText(
        existing,
        'importance',
        source.importance,
        allowOverwrite: true,
      ),
      'userImpactMarkdown': _preserveText(
        existing,
        'userImpactMarkdown',
        textDraft.userImpactMarkdown,
        allowOverwrite: draft != null,
      ),
      'technicalChangesMarkdown': _preserveText(
        existing,
        'technicalChangesMarkdown',
        textDraft.technicalChangesMarkdown,
        allowOverwrite: draft != null,
      ),
      'officialUrl': source.officialUrl,
      'tags': _mergeTags(existing, ['Bitcoin Core', 'Release']),
      'sources': _preserveList(existing, 'sources', [
        {
          'title': 'Bitcoin Core ${source.version} release notes',
          'url': source.releaseNotesUrl,
          'author': 'Bitcoin Core',
        },
        {
          'title': 'Bitcoin Core ${source.version}',
          'url': source.officialUrl,
          'author': 'Bitcoin Core',
        },
      ]),
      'related': _preserveList(existing, 'related', const []),
      if (existing?['reviewedAt'] != null)
        'reviewedAt': existing!['reviewedAt'],
      'updatedAt': now.toIso8601String(),
      'automation': _recordAutomation(
        existing: existing,
        existingAutomation: existingAutomation,
        draft: draft,
        upstreamSha: upstreamSha,
        upstreamUrl: source.releaseNotesUrl,
      ),
    };
  }

  /// Runs a draft request. A thrown error is reported as a warning instead of
  /// aborting the run; the caller decides which text to keep.
  Future<({GeneratedDraft? draft, bool failed})> _requestDraft(
    Future<GeneratedDraft?> Function() request, {
    required String label,
    required String outcome,
    required List<String> warnings,
  }) async {
    try {
      return (draft: await request(), failed: false);
    } on Object catch (error) {
      warnings.add(
        '$label: AI draft failed after retries ($error); $outcome, '
        'the next run will retry.',
      );
      return (draft: null, failed: true);
    }
  }

  /// True when the draft is missing for a reason that should be retried on
  /// the next run: an existing record whose draft was not produced, or a new
  /// record whose draft request failed.
  bool _deferUpstream({
    required JsonMap? existing,
    required bool shouldGenerateDraft,
    required ({GeneratedDraft? draft, bool failed})? draftResult,
  }) {
    if (!shouldGenerateDraft) return false;
    final draftMissing = draftResult?.draft == null;
    if (existing != null) return draftMissing;
    return draftResult?.failed ?? false;
  }

  String? _upstreamShaToStore(
    String sourceSha, {
    required JsonMap existingAutomation,
    required bool deferred,
  }) {
    if (!deferred) return sourceSha;
    final stored = existingAutomation['upstreamSha'];
    return stored is String ? stored : null;
  }

  JsonMap _recordAutomation({
    required JsonMap? existing,
    required JsonMap existingAutomation,
    required GeneratedDraft? draft,
    required String? upstreamSha,
    required String upstreamUrl,
  }) {
    if (draft != null || existing == null) {
      return _automationMetadata(
        upstreamSha: upstreamSha,
        upstreamUrl: upstreamUrl,
        draft: draft,
        needsReview: true,
      );
    }
    return _syncedAutomationMetadata(
      existingAutomation: existingAutomation,
      upstreamSha: upstreamSha,
      upstreamUrl: upstreamUrl,
    );
  }

  /// Keeps an existing non-empty text unless a new draft was generated. The
  /// fallback is used only when the field is missing or blank.
  Object _preserveText(
    JsonMap? existing,
    String key,
    Object fallback, {
    bool allowOverwrite = false,
  }) {
    if (allowOverwrite) {
      return fallback;
    }
    final value = existing?[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return fallback;
  }

  List<Object?> _preserveList(
    JsonMap? existing,
    String key,
    List<Object?> fallback,
  ) {
    final value = existing?[key];
    if (value is List<Object?> && value.isNotEmpty) {
      return value;
    }
    return fallback;
  }

  List<Object?> _mergeTags(
    JsonMap? existing,
    List<String> defaults, {
    Set<String> removeTags = const {},
  }) {
    final tags = <String>{};
    final existingTags = existing?['tags'];
    if (existingTags is List<Object?>) {
      tags.addAll(
        existingTags.whereType<String>().where(
          (tag) => !removeTags.contains(tag),
        ),
      );
    }
    tags.addAll(defaults);
    return tags.toList(growable: false);
  }

  List<Object?> _statusHistoryFor({
    required JsonMap? existing,
    required String newStatus,
    required String sourceLabel,
  }) {
    final history = <Object?>[
      if (existing?['statusHistory'] is List<Object?>)
        ...(existing!['statusHistory'] as List<Object?>),
    ];
    final oldStatus = existing?['status'];
    if (oldStatus is String &&
        normalizeBipStatus(oldStatus) != normalizeBipStatus(newStatus)) {
      history.add({
        'date': now.toIso8601String().split('T').first,
        'status': newStatus,
        'note': 'Status observed as ${_titleCase(newStatus)} in $sourceLabel.',
      });
    }
    return history;
  }

  JsonMap _automationMetadata({
    required String? upstreamSha,
    required String upstreamUrl,
    required GeneratedDraft? draft,
    required bool needsReview,
  }) {
    return {
      'source': 'sync_code_content.dart',
      'upstreamSha': upstreamSha,
      'upstreamUrl': upstreamUrl,
      'aiModel': draft?.model,
      'aiPromptVersion': draft == null ? null : codeAutomationPromptVersion,
      'generatedAt': now.toIso8601String(),
      'needsReview': needsReview,
    }..removeWhere((_, value) => value == null);
  }

  JsonMap _syncedAutomationMetadata({
    required JsonMap existingAutomation,
    required String? upstreamSha,
    required String upstreamUrl,
  }) {
    final metadata = JsonMap.from(existingAutomation)
      ..['source'] = 'sync_code_content.dart'
      ..['upstreamUrl'] = upstreamUrl;
    if (upstreamSha == null) {
      metadata.remove('upstreamSha');
    } else {
      metadata['upstreamSha'] = upstreamSha;
    }
    metadata.putIfAbsent('needsReview', () => false);
    return metadata;
  }
}

abstract interface class CodeSourceClient {
  Future<List<SourceBip>> fetchBips();

  Future<List<SourceRelease>> fetchBitcoinCoreReleases({required int limit});
}

final class HttpCodeSourceClient implements CodeSourceClient {
  HttpCodeSourceClient({
    String? githubToken,
    RetrySleep sleep = defaultRetrySleep,
  }) : _githubToken = githubToken,
       _sleep = sleep;

  final String? _githubToken;
  final RetrySleep _sleep;
  final _client = newCodeSyncHttpClient();

  @override
  Future<List<SourceBip>> fetchBips() async {
    final entries = await _getJsonList(
      Uri.parse(
        'https://api.github.com/repos/bitcoin/bips/contents?ref=master',
      ),
    );
    final files =
        entries
            .where(
              (entry) =>
                  entry['type'] == 'file' &&
                  _bipFilePattern.hasMatch(entry['name'] as String? ?? ''),
            )
            .toList()
          ..sort(
            (a, b) => (a['name'] as String).compareTo(b['name'] as String),
          );

    final bips = <SourceBip>[];
    for (final file in files) {
      final name = file['name'] as String;
      final text = await _getText(Uri.parse(file['download_url'] as String));
      final preamble = BipPreambleParser.parse(text);
      final source = SourceBip.fromPreamble(
        fileName: name,
        sha: file['sha'] as String,
        preamble: preamble,
        sourceText: text,
      );
      bips.add(source);
    }
    return bips;
  }

  @override
  Future<List<SourceRelease>> fetchBitcoinCoreReleases({
    required int limit,
  }) async {
    final entries = await _getJsonList(
      Uri.parse(
        'https://api.github.com/repos/bitcoin/bitcoin/contents/doc/release-notes?ref=master',
      ),
    );
    final publishedDates = await _fetchReleaseDates();
    final releaseFiles =
        entries
            .where(
              (entry) =>
                  entry['type'] == 'file' &&
                  _releaseNotesPattern.hasMatch(entry['name'] as String? ?? ''),
            )
            .toList()
          ..sort((a, b) {
            final aVersion = _releaseNotesPattern
                .firstMatch(a['name'] as String)!
                .group(1)!;
            final bVersion = _releaseNotesPattern
                .firstMatch(b['name'] as String)!
                .group(1)!;
            return VersionParts.parse(
              bVersion,
            ).compareTo(VersionParts.parse(aVersion));
          });

    final releases = <SourceRelease>[];
    for (final file in releaseFiles.take(limit)) {
      final name = file['name'] as String;
      final version = _releaseNotesPattern.firstMatch(name)!.group(1)!;
      final text = await _getText(Uri.parse(file['download_url'] as String));
      final parsed = BitcoinCoreReleaseNoteParser.parse(
        version: version,
        fileName: name,
        sha: file['sha'] as String,
        releaseNotesMarkdown: text,
        releasedAt: publishedDates[version],
      );
      releases.add(parsed);
    }
    return releases;
  }

  Future<Map<String, String>> _fetchReleaseDates() async {
    final releases = await _getJsonList(
      Uri.parse(
        'https://api.github.com/repos/bitcoin/bitcoin/releases?per_page=100',
      ),
    );
    final dates = <String, String>{};
    for (final release in releases) {
      final tagName = release['tag_name'];
      final publishedAt = release['published_at'];
      if (tagName is! String || publishedAt is! String) continue;
      final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;
      dates[version] = publishedAt.split('T').first;
    }
    return dates;
  }

  Future<List<JsonMap>> _getJsonList(Uri uri) async {
    final decoded = jsonDecode(await _getText(uri, json: true));
    if (decoded is! List<Object?>) {
      throw StateError('Expected list response from $uri.');
    }
    return decoded
        .whereType<JsonMap>()
        .map(JsonMap.from)
        .toList(growable: false);
  }

  Future<String> _getText(Uri uri, {bool json = false}) {
    return retryWithBackoff(
      () => _getTextOnce(uri, json: json).timeout(_githubRequestTimeout),
      sleep: _sleep,
      shouldRetry: isRetryableSyncError,
    );
  }

  Future<String> _getTextOnce(Uri uri, {required bool json}) async {
    final request = await _client.getUrl(uri);
    request.headers.set(HttpHeaders.userAgentHeader, 'SatoWiki-Code-Sync');
    if (json) {
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/vnd.github+json',
      );
      request.headers.set('X-GitHub-Api-Version', '2022-11-28');
      if (_githubToken != null && uri.host == 'api.github.com') {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $_githubToken',
        );
      }
    }
    final response = await request.close();
    final text = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CodeSyncHttpException(
        statusCode: response.statusCode,
        message: 'GET $uri failed with ${response.statusCode}: $text',
      );
    }
    return text;
  }

  void close() {
    _client.close(force: true);
  }
}

final class BipPreambleParser {
  const BipPreambleParser._();

  static Map<String, String> parse(String source) {
    final text = source.replaceAll('\r\n', '\n');
    final header = _extractHeader(text);
    final values = <String, String>{};
    String? currentKey;

    for (final rawLine in header.split('\n')) {
      final line = rawLine.replaceFirst(_trailingWhitespace, '');
      if (line.trim().isEmpty) continue;
      final trimmedLeft = line.trimLeft();
      final colonIndex = trimmedLeft.indexOf(':');
      final key = colonIndex > 0
          ? trimmedLeft.substring(0, colonIndex).trim()
          : null;
      if (key != null && _preambleKeyPattern.hasMatch(key)) {
        currentKey = key;
        values[currentKey] = trimmedLeft.substring(colonIndex + 1).trim();
      } else if (currentKey != null && rawLine.startsWith(RegExp(r'\s'))) {
        final continuation = line.trim();
        if (continuation.isNotEmpty) {
          values[currentKey] = '${values[currentKey]}\n$continuation';
        }
      }
    }

    if (!values.containsKey('BIP')) {
      throw const FormatException('Missing BIP preamble.');
    }
    return values;
  }

  static String _extractHeader(String text) {
    if (text.startsWith('```')) {
      final end = text.indexOf('\n```', 3);
      if (end == -1) {
        throw const FormatException('Unclosed Markdown preamble fence.');
      }
      final firstLineEnd = text.indexOf('\n');
      return text.substring(firstLineEnd + 1, end);
    }

    final mediaWikiEnd = text.indexOf('\n==');
    if (mediaWikiEnd != -1) {
      return text.substring(0, mediaWikiEnd);
    }

    final markdownEnd = text.indexOf('\n##');
    if (markdownEnd != -1) {
      return text.substring(0, markdownEnd);
    }

    return text;
  }
}

final class SourceBip {
  const SourceBip({
    required this.number,
    required this.fileName,
    required this.sha,
    required this.title,
    required this.status,
    required this.category,
    required this.authors,
    required this.assignedAt,
    required this.officialUrl,
    required this.rawTextExcerpt,
  });

  final int number;
  final String fileName;
  final String sha;
  final String title;
  final String status;
  final String category;
  final List<String> authors;
  final String? assignedAt;
  final String officialUrl;
  final String rawTextExcerpt;

  static SourceBip fromPreamble({
    required String fileName,
    required String sha,
    required Map<String, String> preamble,
    String? sourceText,
  }) {
    final number = int.parse(preamble['BIP']!.replaceAll('?', '').trim());
    final rawStatus = preamble['Status'] ?? 'Draft';
    // An unknown status is kept as written; the sync skips or freezes that BIP.
    final status = bipStatusOrNull(rawStatus) ?? rawStatus.trim();
    final layer = preamble['Layer'];
    final type = preamble['Type'];
    return SourceBip(
      number: number,
      fileName: fileName,
      sha: sha,
      title: preamble['Title']?.trim() ?? 'BIP $number',
      status: status,
      category: normalizeBipCategory(layer ?? type ?? 'process'),
      authors: parseAuthors(preamble['Authors'] ?? ''),
      assignedAt: _normalizeDate(preamble['Assigned']),
      officialUrl: 'https://github.com/bitcoin/bips/blob/master/$fileName',
      rawTextExcerpt: sourceText == null
          ? preamble.entries
                .map((entry) => '${entry.key}: ${entry.value}')
                .join('\n')
          : _trimBipSourceText(sourceText),
    );
  }

  static String _trimBipSourceText(String sourceText) {
    final normalized = sourceText.replaceAll('\r\n', '\n').trim();
    if (normalized.length <= 16000) return normalized;
    return '${normalized.substring(0, 16000)}\n\n[BIP text truncated for AI drafting.]';
  }
}

final class BitcoinCoreReleaseNoteParser {
  const BitcoinCoreReleaseNoteParser._();

  static SourceRelease parse({
    required String version,
    required String fileName,
    required String sha,
    required String releaseNotesMarkdown,
    required String? releasedAt,
  }) {
    return SourceRelease(
      version: version,
      fileName: fileName,
      sha: sha,
      releasedAt: releasedAt,
      importance: VersionParts.parse(version).releaseImportance,
      officialUrl: 'https://bitcoincore.org/en/releases/$version/',
      releaseNotesUrl:
          'https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/$fileName',
      releaseNotesMarkdown: _trimReleaseNotes(releaseNotesMarkdown),
    );
  }

  static String _trimReleaseNotes(String markdown) {
    final normalized = markdown.replaceAll('\r\n', '\n').trim();
    if (normalized.length <= 16000) return normalized;
    return '${normalized.substring(0, 16000)}\n\n[Release notes truncated for AI drafting.]';
  }
}

final class SourceRelease {
  const SourceRelease({
    required this.version,
    required this.fileName,
    required this.sha,
    required this.releasedAt,
    required this.importance,
    required this.officialUrl,
    required this.releaseNotesUrl,
    required this.releaseNotesMarkdown,
  });

  final String version;
  final String fileName;
  final String sha;
  final String? releasedAt;
  final String importance;
  final String officialUrl;
  final String releaseNotesUrl;
  final String releaseNotesMarkdown;
}

abstract interface class CodeContentDraftClient {
  Future<GeneratedDraft?> generateBipDraft(SourceBip source, String language);

  Future<GeneratedDraft?> generateReleaseDraft(
    SourceRelease source,
    String language,
  );
}

final class NullCodeContentDraftClient implements CodeContentDraftClient {
  @override
  Future<GeneratedDraft?> generateBipDraft(SourceBip source, String language) {
    return Future.value();
  }

  @override
  Future<GeneratedDraft?> generateReleaseDraft(
    SourceRelease source,
    String language,
  ) {
    return Future.value();
  }
}

final class GeminiCodeContentDraftClient implements CodeContentDraftClient {
  GeminiCodeContentDraftClient({
    required this.apiKey,
    required this.model,
    HttpClient? httpClient,
    RetrySleep sleep = defaultRetrySleep,
  }) : _client = httpClient ?? newCodeSyncHttpClient(),
       _sleep = sleep;

  final String apiKey;
  final String model;
  final HttpClient _client;
  final RetrySleep _sleep;

  static CodeContentDraftClient fromEnvironment(Map<String, String> env) {
    final apiKey = env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return NullCodeContentDraftClient();
    }
    return GeminiCodeContentDraftClient(
      apiKey: apiKey,
      model: env['GEMINI_MODEL'] ?? defaultGeminiModel,
    );
  }

  @override
  Future<GeneratedDraft?> generateBipDraft(SourceBip source, String language) {
    final prompt =
        '''
You are drafting reviewed SatoWiki content for the Code section.
Language: $language.
Source: official Bitcoin BIP metadata only.
Write concise, neutral, technically careful copy. Do not claim community consensus beyond the BIP status.

BIP ${source.number}: ${source.title}
Status: ${source.status}
Category: ${source.category}
Authors: ${source.authors.join(', ')}
Assigned: ${source.assignedAt ?? 'unknown'}
Official URL: ${source.officialUrl}

Metadata:
${source.rawTextExcerpt}
''';
    return _generateDraft(prompt, _bipDraftSchema);
  }

  @override
  Future<GeneratedDraft?> generateReleaseDraft(
    SourceRelease source,
    String language,
  ) {
    final prompt =
        '''
You are drafting reviewed SatoWiki content for the Code section.
Language: $language.
Source: official Bitcoin Core release notes only.
Write concise, neutral, technically careful copy for Bitcoin users and technical readers.

Bitcoin Core ${source.version}
Release URL: ${source.officialUrl}
Release notes URL: ${source.releaseNotesUrl}

Official release notes:
${source.releaseNotesMarkdown}
''';
    return _generateDraft(prompt, _releaseDraftSchema);
  }

  Future<GeneratedDraft?> _generateDraft(String prompt, JsonMap schema) {
    return retryWithBackoff(
      () => _generateDraftOnce(prompt, schema).timeout(_geminiRequestTimeout),
      sleep: _sleep,
      shouldRetry: isRetryableSyncError,
    );
  }

  Future<GeneratedDraft?> _generateDraftOnce(
    String prompt,
    JsonMap schema,
  ) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );
    final request = await _client.postUrl(uri);
    request.headers.set('x-goog-api-key', apiKey);
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'application/json; charset=utf-8',
    );
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseFormat': {
          'text': {'mimeType': 'APPLICATION_JSON', 'schema': schema},
        },
      },
    };
    request.write(jsonEncode(body));
    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CodeSyncHttpException(
        statusCode: response.statusCode,
        message:
            'Gemini request failed with ${response.statusCode}: $responseBody',
      );
    }
    return parseResponse(responseBody, model: model);
  }

  static GeneratedDraft parseResponse(
    String responseBody, {
    required String model,
  }) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! JsonMap) {
      throw const FormatException('Gemini response root must be an object.');
    }
    final candidates = decoded['candidates'];
    if (candidates is! List<Object?> || candidates.isEmpty) {
      throw const FormatException(
        'Gemini response did not include candidates.',
      );
    }
    final candidate = candidates.first;
    if (candidate is! JsonMap) {
      throw const FormatException('Gemini candidate must be an object.');
    }
    final content = candidate['content'];
    if (content is! JsonMap) {
      throw const FormatException(
        'Gemini candidate content must be an object.',
      );
    }
    final parts = content['parts'];
    if (parts is! List<Object?> || parts.isEmpty) {
      throw const FormatException('Gemini candidate content has no parts.');
    }
    final firstPart = parts.first;
    if (firstPart is! JsonMap || firstPart['text'] is! String) {
      throw const FormatException('Gemini text part missing.');
    }
    final draftJson = jsonDecode(firstPart['text'] as String);
    if (draftJson is! JsonMap) {
      throw const FormatException('Gemini draft must be a JSON object.');
    }
    return GeneratedDraft.fromJson(draftJson, model: model);
  }
}

final class GeneratedDraft {
  const GeneratedDraft({
    required this.summary,
    required this.summaryMarkdown,
    required this.impactMarkdown,
    required this.userImpactMarkdown,
    required this.technicalChangesMarkdown,
    required this.model,
  });

  final String summary;
  final String summaryMarkdown;
  final String impactMarkdown;
  final String userImpactMarkdown;
  final String technicalChangesMarkdown;
  final String? model;

  static GeneratedDraft fromJson(JsonMap json, {required String model}) {
    String field(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Gemini draft field "$key" must be non-empty.');
      }
      return value.trim();
    }

    return GeneratedDraft(
      summary: field('summary'),
      summaryMarkdown: field('summaryMarkdown'),
      impactMarkdown: field('impactMarkdown'),
      userImpactMarkdown: field('userImpactMarkdown'),
      technicalChangesMarkdown: field('technicalChangesMarkdown'),
      model: model,
    );
  }

  static GeneratedDraft bipFallback(SourceBip source, String language) {
    final isItalian = language == 'it';
    return GeneratedDraft(
      summary: isItalian
          ? 'BIP ${source.number}: ${source.title}.'
          : 'BIP ${source.number}: ${source.title}.',
      summaryMarkdown: isItalian
          ? 'Bozza generata dai metadati ufficiali del BIP. Richiede revisione tecnica prima della pubblicazione editoriale.'
          : 'Draft generated from official BIP metadata. Requires technical review before editorial publication.',
      impactMarkdown: isItalian
          ? 'Impatto da verificare durante la review del maintainer.'
          : 'Impact to be verified during maintainer review.',
      userImpactMarkdown: '',
      technicalChangesMarkdown: '',
      model: null,
    );
  }

  static GeneratedDraft releaseFallback(SourceRelease source, String language) {
    final isItalian = language == 'it';
    return GeneratedDraft(
      summary: isItalian
          ? 'Release Bitcoin Core ${source.version}.'
          : 'Bitcoin Core ${source.version} release.',
      summaryMarkdown: '',
      impactMarkdown: '',
      userImpactMarkdown: isItalian
          ? 'Bozza generata dalle note ufficiali. Richiede review.'
          : 'Draft generated from official release notes. Requires review.',
      technicalChangesMarkdown: isItalian
          ? 'Modifiche tecniche da sintetizzare durante la review.'
          : 'Technical changes to summarize during review.',
      model: null,
    );
  }
}

final class VersionParts implements Comparable<VersionParts> {
  const VersionParts(this.parts);

  final List<int> parts;

  /// `X.0` and `X.0.0` are major, `X.Y` with Y > 0 is minor, and a non-zero
  /// third component is a patch release.
  String get releaseImportance {
    if (parts.skip(2).any((part) => part != 0)) return 'patch';
    return parts.length < 2 || parts[1] == 0 ? 'major' : 'minor';
  }

  static VersionParts parse(String value) {
    return VersionParts(
      value
          .split('.')
          .map(
            (part) => int.tryParse(part.replaceAll(RegExp(r'\D.*$'), '')) ?? 0,
          )
          .toList(growable: false),
    );
  }

  @override
  int compareTo(VersionParts other) {
    final length = parts.length > other.parts.length
        ? parts.length
        : other.parts.length;
    for (var i = 0; i < length; i += 1) {
      final a = i < parts.length ? parts[i] : 0;
      final b = i < other.parts.length ? other.parts[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }
}

final class CodeSyncReport {
  const CodeSyncReport({
    required this.generatedAt,
    required this.bipsFetched,
    required this.releasesFetched,
    required this.languages,
  });

  final DateTime generatedAt;
  final int bipsFetched;
  final int releasesFetched;
  final List<LanguageSyncReport> languages;

  String toConsoleString() {
    final buffer = StringBuffer()
      ..writeln('Fetched $bipsFetched BIPs and $releasesFetched releases.');
    for (final language in languages) {
      buffer.writeln(
        '${language.language}: bips=${language.bipCount} '
        'releases=${language.releaseCount} changed=${language.changed}',
      );
      for (final warning in language.warnings) {
        buffer.writeln('${language.language} warning: $warning');
      }
    }
    return buffer.toString().trimRight();
  }

  String toMarkdown() {
    final buffer = StringBuffer()
      ..writeln('# SatoWiki Code Content Sync')
      ..writeln()
      ..writeln('- Generated at: `${generatedAt.toIso8601String()}`')
      ..writeln('- BIPs fetched: `$bipsFetched`')
      ..writeln('- Bitcoin Core releases fetched: `$releasesFetched`')
      ..writeln();
    for (final language in languages) {
      buffer
        ..writeln('## ${language.language}')
        ..writeln()
        ..writeln('- Changed: `${language.changed}`')
        ..writeln('- BIP records: `${language.bipCount}`')
        ..writeln('- Release records: `${language.releaseCount}`');
      if (language.changedItems.isNotEmpty) {
        buffer.writeln('- Changed items:');
        for (final item in language.changedItems.take(50)) {
          buffer.writeln('  - $item');
        }
        if (language.changedItems.length > 50) {
          buffer.writeln(
            '  - ...and ${language.changedItems.length - 50} more',
          );
        }
      }
      if (language.warnings.isNotEmpty) {
        buffer.writeln('- Warnings:');
        for (final warning in language.warnings) {
          buffer.writeln('  - $warning');
        }
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}

final class LanguageSyncReport {
  const LanguageSyncReport({
    required this.language,
    required this.changed,
    required this.changedItems,
    required this.warnings,
    required this.bipCount,
    required this.releaseCount,
  });

  final String language;
  final bool changed;
  final List<String> changedItems;
  final List<String> warnings;
  final int bipCount;
  final int releaseCount;
}

String normalizeBipStatus(String status) {
  return bipStatusOrNull(status) ??
      (throw FormatException('Unsupported BIP status: $status'));
}

/// Returns the canonical BIP status, or null when the status is not known.
String? bipStatusOrNull(String status) {
  final normalized = status.trim().toLowerCase().replaceAll(' ', '-');
  return switch (normalized) {
    'draft' || 'proposed' || 'bip-number-allocated' => 'draft',
    'complete' || 'final' => 'complete',
    'deployed' || 'active' => 'deployed',
    'closed' || 'withdrawn' || 'rejected' => 'closed',
    _ => null,
  };
}

/// A failed HTTP response, kept typed so the retry policy can read the status.
final class CodeSyncHttpException implements Exception {
  const CodeSyncHttpException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

Future<void> defaultRetrySleep(Duration delay) => Future<void>.delayed(delay);

HttpClient newCodeSyncHttpClient() {
  return HttpClient()..connectionTimeout = _connectionTimeout;
}

/// Timeouts, dropped sockets, HTTP 429 and HTTP 5xx are transient. Other 4xx
/// responses and parsing errors are not retried.
bool isRetryableSyncError(Object error) {
  if (error is CodeSyncHttpException) {
    return error.statusCode == 429 || error.statusCode >= 500;
  }
  return error is TimeoutException ||
      error is SocketException ||
      error is HttpException;
}

/// Runs [action] up to [_maxRequestAttempts] times with exponential backoff.
Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  required RetrySleep sleep,
  required bool Function(Object error) shouldRetry,
  int maxAttempts = _maxRequestAttempts,
  Duration baseDelay = _retryBaseDelay,
}) async {
  for (var attempt = 1; ; attempt += 1) {
    try {
      return await action();
    } on Object catch (error) {
      if (attempt >= maxAttempts || !shouldRetry(error)) rethrow;
      await sleep(baseDelay * (1 << (attempt - 1)));
    }
  }
}

String normalizeBipCategory(String value) {
  final normalized = value.toLowerCase();
  if (normalized.contains('consensus')) return 'consensus';
  if (normalized.contains('peer')) return 'peer-services';
  if (normalized.contains('application')) return 'applications';
  if (normalized.contains('api') || normalized.contains('rpc')) {
    return 'api-rpc';
  }
  if (normalized.contains('process')) return 'process';
  if (normalized.contains('informational')) return 'informational';
  if (normalized.contains('standard')) return 'standards';
  return normalized
      .replaceAll(RegExp(r'\([^)]*\)'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

List<String> parseAuthors(String value) {
  final authors = <String>[];
  for (final line in value.split('\n')) {
    final pieces = line.contains(',') ? line.split(',') : [line];
    for (final piece in pieces) {
      final author = piece
          .replaceAll(RegExp(r'<[^>]+>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (author.isNotEmpty) {
        authors.add(author);
      }
    }
  }
  return authors;
}

Map<String, JsonMap> _indexedById(Object? value) {
  if (value is! List<Object?>) return const {};
  final indexed = <String, JsonMap>{};
  for (final item in value) {
    if (item is! JsonMap) continue;
    final id = item['id'];
    if (id is String) {
      indexed[id] = JsonMap.from(item);
    }
  }
  return indexed;
}

JsonMap _automation(JsonMap? existing) {
  final automation = existing?['automation'];
  return automation is JsonMap ? automation : const {};
}

/// True for a record that was created without a draft and never reviewed: it
/// still shows the placeholder text, so it needs a first draft even though
/// upstream has not changed.
bool _stillHasPlaceholder(JsonMap existing, String key, Object? placeholder) {
  return _automation(existing)['needsReview'] == true &&
      placeholder is String &&
      existing[key] == placeholder;
}

bool _isAiManaged(JsonMap? existing) {
  final automation = _automation(existing);
  return automation['needsReview'] == true || automation['aiModel'] is String;
}

bool _jsonDeepEquals(Object? a, Object? b) {
  return jsonEncode(a) == jsonEncode(b);
}

/// A record is unchanged when everything except `updatedAt` matches the
/// stored record. Unchanged records keep their stored `updatedAt`.
bool _isUnchanged(JsonMap? existing, JsonMap record) {
  if (existing == null || existing['updatedAt'] is! String) return false;
  return _jsonDeepEquals(
    _withoutUpdatedAt(existing),
    _withoutUpdatedAt(record),
  );
}

JsonMap _withoutUpdatedAt(JsonMap record) {
  return JsonMap.from(record)..remove('updatedAt');
}

String _bundleVersion(DateTime now) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${now.year}.${two(now.month)}.${two(now.day)}.'
      '${two(now.hour)}${two(now.minute)}${two(now.second)}';
}

String _titleCase(String value) {
  return value
      .split(RegExp(r'[-_\s]+'))
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String? _normalizeDate(String? value) {
  if (value == null) return null;
  final match = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(value);
  return match?.group(0);
}

final _bipFilePattern = RegExp(r'^bip-\d{4}\.(mediawiki|md)$');
final _releaseNotesPattern = RegExp(
  r'^release-notes-([0-9]+(?:\.[0-9]+)*)\.md$',
);
final _preambleKeyPattern = RegExp(r'^[A-Za-z][A-Za-z-]*$');
final _trailingWhitespace = RegExp(r'\s+$');

const _bipDraftSchema = {
  'type': 'object',
  'properties': {
    'summary': {'type': 'string'},
    'summaryMarkdown': {'type': 'string'},
    'impactMarkdown': {'type': 'string'},
    'userImpactMarkdown': {'type': 'string'},
    'technicalChangesMarkdown': {'type': 'string'},
  },
  'required': [
    'summary',
    'summaryMarkdown',
    'impactMarkdown',
    'userImpactMarkdown',
    'technicalChangesMarkdown',
  ],
};

const _releaseDraftSchema = {
  'type': 'object',
  'properties': {
    'summary': {'type': 'string'},
    'summaryMarkdown': {'type': 'string'},
    'impactMarkdown': {'type': 'string'},
    'userImpactMarkdown': {'type': 'string'},
    'technicalChangesMarkdown': {'type': 'string'},
  },
  'required': [
    'summary',
    'summaryMarkdown',
    'impactMarkdown',
    'userImpactMarkdown',
    'technicalChangesMarkdown',
  ],
};
