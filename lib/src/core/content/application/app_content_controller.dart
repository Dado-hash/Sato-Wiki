import 'package:flutter/foundation.dart';

import '../../localization/app_locale.dart';
import '../../search/search_index.dart';
import '../app_content.dart';
import '../data/content_bundle_parser.dart';
import '../data/content_bundle_repository.dart';
import '../data/content_media_store.dart';
import '../domain/content_media.dart';
import '../domain/content_models.dart';
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
       _requestedLanguageCode = languageCode,
       _content = content,
       _updater = updater,
       _mediaStore = mediaStore;

  final ContentBundleRepository _repository;
  final BackgroundContentUpdater? _updater;
  final ContentMediaStore? _mediaStore;

  /// Language whose content is applied.
  String _languageCode;

  /// Most recently requested language. It differs from [_languageCode] while
  /// a language load is in flight, and a result is applied only if it still
  /// matches this value.
  String _requestedLanguageCode;
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
    _requestedLanguageCode = normalizedLanguageCode;
    if (normalizedLanguageCode == _languageCode) {
      return;
    }

    final content = await _loadContent(
      _repository,
      normalizedLanguageCode,
      _mediaStore,
    );
    if (_requestedLanguageCode != normalizedLanguageCode) {
      // A newer request arrived while this one was loading.
      return;
    }

    _languageCode = normalizedLanguageCode;
    _content = content;
    notifyListeners();
  }

  Future<void> checkForUpdates() async {
    final updater = _updater;
    if (updater == null) {
      _setUpdateProgress(
        const UpdateProgress(state: UpdateState.idle, progress: 0),
      );
      return;
    }

    final checkedLanguageCode = _languageCode;
    _setUpdateProgress(
      const UpdateProgress(state: UpdateState.checking, progress: 0.05),
    );

    try {
      // The updater fetches the manifest once and decides whether there is
      // anything to download. Only then does it report downloadingBundle.
      final result = await updater.checkForUpdates(
        checkedLanguageCode,
        onWorkStarted: () {
          _setUpdateProgress(
            const UpdateProgress(
              state: UpdateState.downloadingBundle,
              progress: 0.15,
            ),
          );
        },
        onMediaProgress: (current, total) {
          final mediaProgress = total > 0 ? current / total : 0.0;
          _setUpdateProgress(
            UpdateProgress(
              state: UpdateState.downloadingMedia,
              progress: 0.15 + 0.8 * mediaProgress,
              mediaFilesDownloaded: current,
              mediaFilesTotal: total,
            ),
          );
        },
      );

      if (checkedLanguageCode != _languageCode ||
          checkedLanguageCode != _requestedLanguageCode) {
        // The language changed while checking, so this result is stale.
        _setUpdateProgress(
          const UpdateProgress(state: UpdateState.idle, progress: 0),
        );
        return;
      }

      if (result == null) {
        _setUpdateProgress(
          const UpdateProgress(state: UpdateState.idle, progress: 0),
        );
        return;
      }

      _setUpdateProgress(
        const UpdateProgress(state: UpdateState.installing, progress: 0.95),
      );

      _content = _contentFromResult(result, _mediaStore);
      _setUpdateProgress(
        const UpdateProgress(state: UpdateState.done, progress: 1.0),
      );
    } on Object {
      _setUpdateProgress(
        const UpdateProgress(state: UpdateState.error, progress: 0),
      );
    }
  }

  void _setUpdateProgress(UpdateProgress progress) {
    _updateProgress = progress;
    notifyListeners();
  }

  /// Loads the bundle for [languageCode] and installs its seed media.
  ///
  /// Startup must never fail because of a stored bundle. If a stored update
  /// cannot have its media installed, it is discarded and the seed is used.
  /// If the seed itself cannot have its media installed, its text is still
  /// shown without the failed media.
  static Future<AppContent> _loadContent(
    ContentBundleRepository repository,
    String languageCode,
    ContentMediaStore? mediaStore,
  ) async {
    var result = await repository.load(languageCode);
    if (mediaStore != null &&
        !await _installBundleMedia(mediaStore, result.bundle)) {
      if (repository
          case final DiscardableContentBundleRepository discardable) {
        await discardable.discardUpdatedBundle(languageCode);
        result = await repository.load(languageCode);
        await _installBundleMedia(mediaStore, result.bundle);
      }
    }

    return _contentFromResult(result, mediaStore);
  }

  /// Returns false instead of throwing, so one bad bundle cannot stop startup.
  static Future<bool> _installBundleMedia(
    ContentMediaStore mediaStore,
    ContentBundle bundle,
  ) async {
    try {
      await mediaStore.installBundleMediaFromAssets(bundle: bundle);

      return true;
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Content media could not be installed: $error');
      }

      return false;
    }
  }

  static AppContent _contentFromResult(
    ContentBundleParseResult result,
    ContentMediaStore? mediaStore,
  ) {
    if (kDebugMode) {
      for (final warning in result.warnings) {
        debugPrint('Content warning at ${warning.path}: ${warning.message}');
      }
    }

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
}
