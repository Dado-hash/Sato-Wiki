import 'package:flutter/foundation.dart';

import '../../localization/app_locale.dart';
import '../../search/search_index.dart';
import '../app_content.dart';
import '../data/content_bundle_parser.dart';
import '../data/content_bundle_repository.dart';
import '../data/content_media_store.dart';
import '../domain/content_media.dart';
import '../domain/content_store.dart';

final class UpdateProgress {
  const UpdateProgress({
    required this.state,
    required this.progress,
    this.mediaFilesDownloaded = 0,
    this.mediaFilesTotal = 0,
  });

  final UpdateState state;
  final double progress;
  final int mediaFilesDownloaded;
  final int mediaFilesTotal;
}

enum UpdateState {
  idle,
  checking,
  downloadingBundle,
  downloadingMedia,
  installing,
  done,
  error,
}

final class AppContentController extends ChangeNotifier {
  AppContentController._({
    required ContentBundleRepository repository,
    required String languageCode,
    required AppContent content,
    BackgroundContentUpdater? updater,
    ContentMediaStore? mediaStore,
  }) : _repository = repository,
       _languageCode = languageCode,
       _content = content,
       _updater = updater,
       _mediaStore = mediaStore;

  final ContentBundleRepository _repository;
  final BackgroundContentUpdater? _updater;
  final ContentMediaStore? _mediaStore;

  String _languageCode;
  AppContent _content;
  UpdateProgress _updateProgress = const UpdateProgress(
    state: UpdateState.idle,
    progress: 0,
  );

  String get languageCode => _languageCode;

  AppContent get content => _content;

  UpdateProgress get updateProgress => _updateProgress;

  static Future<AppContentController> load({
    required ContentBundleRepository repository,
    required String languageCode,
    BackgroundContentUpdater? updater,
    ContentMediaStore? mediaStore,
  }) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    final content = await _loadContent(
      repository,
      normalizedLanguageCode,
      mediaStore,
    );

    return AppContentController._(
      repository: repository,
      updater: updater,
      mediaStore: mediaStore,
      languageCode: normalizedLanguageCode,
      content: content,
    );
  }

  Future<void> loadLanguage(String languageCode) async {
    final normalizedLanguageCode = AppLocale.normalizeLanguageCode(
      languageCode,
    );
    if (normalizedLanguageCode == _languageCode) {
      return;
    }

    final content = await _loadContent(
      _repository,
      normalizedLanguageCode,
      _mediaStore,
    );
    _languageCode = normalizedLanguageCode;
    _content = content;
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    final updater = _updater;
    if (updater == null) {
      _updateProgress = const UpdateProgress(
        state: UpdateState.idle,
        progress: 0,
      );
      notifyListeners();
      return;
    }

    _updateProgress = const UpdateProgress(
      state: UpdateState.checking,
      progress: 0.05,
    );
    notifyListeners();

    try {
      final manifest = await updater.fetchManifest(_languageCode);
      if (manifest == null) {
        _updateProgress = const UpdateProgress(
          state: UpdateState.idle,
          progress: 0,
        );
        notifyListeners();
        return;
      }

      final current = await _repository.load(_languageCode);
      final isNewer = _isNewerVersion(manifest.version, current.bundle.version);
      if (!isNewer) {
        _updateProgress = const UpdateProgress(
          state: UpdateState.idle,
          progress: 0,
        );
        notifyListeners();
        return;
      }

      _updateProgress = const UpdateProgress(
        state: UpdateState.downloadingBundle,
        progress: 0.15,
      );
      notifyListeners();

      final result = await updater.checkForUpdates(
        _languageCode,
        onMediaProgress: (current, total) {
          final mediaProgress = total > 0 ? current / total : 0.0;
          _updateProgress = UpdateProgress(
            state: UpdateState.downloadingMedia,
            progress: 0.15 + 0.8 * mediaProgress,
            mediaFilesDownloaded: current,
            mediaFilesTotal: total,
          );
          notifyListeners();
        },
      );

      if (result == null) {
        _updateProgress = const UpdateProgress(
          state: UpdateState.idle,
          progress: 0,
        );
        notifyListeners();
        return;
      }

      _updateProgress = const UpdateProgress(
        state: UpdateState.installing,
        progress: 0.95,
      );
      notifyListeners();

      _content = _contentFromResult(result, _mediaStore);
      _updateProgress = const UpdateProgress(
        state: UpdateState.done,
        progress: 1.0,
      );
      notifyListeners();
    } on Object {
      _updateProgress = const UpdateProgress(
        state: UpdateState.error,
        progress: 0,
      );
      notifyListeners();
    }
  }

  static Future<AppContent> _loadContent(
    ContentBundleRepository repository,
    String languageCode,
    ContentMediaStore? mediaStore,
  ) async {
    final result = await repository.load(languageCode);
    await mediaStore?.installBundleMediaFromAssets(bundle: result.bundle);

    return _contentFromResult(result, mediaStore);
  }

  static AppContent _contentFromResult(
    ContentBundleParseResult result,
    ContentMediaStore? mediaStore,
  ) {
    final store = ContentStore(result.bundle);

    return AppContent(
      store: store,
      searchIndex: SearchIndex.fromBundle(result.bundle),
      mediaResolver:
          mediaStore?.resolverFor(
            language: result.bundle.language,
            version: result.bundle.version,
          ) ??
          ContentMediaResolver.empty,
      warnings: result.warnings,
    );
  }

  bool _isNewerVersion(String candidate, String current) {
    final candidateParts = _versionParts(candidate);
    final currentParts = _versionParts(current);
    if (candidateParts != null && currentParts != null) {
      final length = candidateParts.length > currentParts.length
          ? candidateParts.length
          : currentParts.length;
      for (var i = 0; i < length; i++) {
        final candidateValue = i < candidateParts.length
            ? candidateParts[i]
            : 0;
        final currentValue = i < currentParts.length ? currentParts[i] : 0;
        if (candidateValue != currentValue) {
          return candidateValue > currentValue;
        }
      }

      return false;
    }

    return candidate.compareTo(current) > 0;
  }

  List<int>? _versionParts(String version) {
    final parts = version.split('.');
    final values = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null) {
        return null;
      }
      values.add(value);
    }

    return values;
  }
}
