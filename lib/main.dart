import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
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

  runApp(SatoWikiApp(settingsController: settingsController));
}
