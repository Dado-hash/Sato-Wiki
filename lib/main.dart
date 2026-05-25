import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/core/content/app_content.dart';
import 'src/core/content/data/content_bundle_repository.dart';
import 'src/core/content/domain/content_store.dart';
import 'src/core/search/search_index.dart';
import 'src/core/settings/app_settings_controller.dart';
import 'src/core/settings/shared_preferences_app_settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final settingsRepository = SharedPreferencesAppSettingsRepository(
    preferences,
  );
  final settingsController = await AppSettingsController.load(
    settingsRepository,
  );
  final contentRepository = LocalFirstContentBundleRepository(
    preferences: preferences,
  );
  final contentResult = await contentRepository.load();
  final store = ContentStore(contentResult.bundle);
  final appContent = AppContent(
    store: store,
    searchIndex: SearchIndex.fromBundle(contentResult.bundle),
    warnings: contentResult.warnings,
  );

  runApp(
    SatoWikiApp(settingsController: settingsController, appContent: appContent),
  );
}
