import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'content_bundle_parser.dart';

abstract interface class ContentBundleRepository {
  Future<ContentBundleParseResult> load();

  Future<void> saveUpdatedBundleJson(String json);
}

final class LocalFirstContentBundleRepository
    implements ContentBundleRepository {
  LocalFirstContentBundleRepository({
    required SharedPreferences preferences,
    AssetBundle? assetBundle,
  }) : _preferences = preferences,
       _assetBundle = assetBundle ?? rootBundle;

  static const seedAssetPath = 'assets/content/seed_bundle.json';
  static const _updatedBundleKey = 'content.updatedBundleJson';

  final SharedPreferences _preferences;
  final AssetBundle _assetBundle;

  @override
  Future<ContentBundleParseResult> load() async {
    final updatedJson = _preferences.getString(_updatedBundleKey);
    if (updatedJson != null) {
      try {
        return ContentBundleParser.parseJson(updatedJson);
      } on Object {
        // Bad updates must not block offline seed content.
      }
    }

    final seedJson = await _assetBundle.loadString(seedAssetPath);

    return ContentBundleParser.parseJson(seedJson);
  }

  @override
  Future<void> saveUpdatedBundleJson(String json) async {
    ContentBundleParser.parseJson(json);
    await _preferences.setString(_updatedBundleKey, json);
  }
}

final class ContentManifest {
  const ContentManifest({
    required this.version,
    required this.schemaVersion,
    required this.bundleUrl,
    required this.sha256,
  });

  final String version;
  final int schemaVersion;
  final Uri bundleUrl;
  final String sha256;
}

abstract interface class RemoteContentManifestRepository {
  Future<ContentManifest?> fetchManifest();
}

abstract interface class BackgroundContentUpdater {
  Future<void> checkForUpdates();
}
