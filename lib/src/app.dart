import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/app_settings_controller.dart';

class SatoWikiApp extends StatelessWidget {
  const SatoWikiApp({required this.settingsController, super.key});

  final AppSettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SatoWiki',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: settingsController.lastTab.routePath,
      onGenerateRoute: (settings) {
        return AppRouter.generateRoute(settings, settingsController);
      },
    );
  }
}
