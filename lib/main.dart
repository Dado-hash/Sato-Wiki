import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/core/content/application/app_content_controller.dart';
import 'src/core/content/data/content_bundle_repository.dart';
import 'src/core/localization/app_locale.dart';
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
  final contentUpdater = VerifiedBackgroundContentUpdater(
    localRepository: contentRepository,
    manifestRepository: const GitHubPagesContentManifestRepository(),
    downloader: const HttpContentBundleDownloader(),
  );
  final languageCode = AppLocale.resolveLanguageCode(
    settingsController.localePreference,
    WidgetsBinding.instance.platformDispatcher.locales,
  );
  final contentController = await AppContentController.load(
    repository: contentRepository,
    updater: contentUpdater,
    languageCode: languageCode,
  );

  runApp(
    SatoWikiApp(
      settingsController: settingsController,
      contentController: contentController,
    ),
  );
}
