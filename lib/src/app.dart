import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/content/application/app_content_controller.dart';
import 'core/localization/app_locale.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/settings/app_settings_controller.dart';
import 'core/widgets/update_progress_dialog.dart';
import 'generated/l10n/app_localizations.dart';

class SatoWikiApp extends StatefulWidget {
  const SatoWikiApp({
    required this.settingsController,
    required this.contentController,
    super.key,
  });

  final AppSettingsController settingsController;
  final AppContentController contentController;

  @override
  State<SatoWikiApp> createState() => _SatoWikiAppState();
}

class _SatoWikiAppState extends State<SatoWikiApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.settingsController.addListener(_handleAppStateChanged);
    widget.contentController.addListener(_handleAppStateChanged);
    widget.contentController.addListener(_handleUpdateProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.contentController.checkForUpdates();
    });
  }

  @override
  void didUpdateWidget(SatoWikiApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settingsController != widget.settingsController) {
      oldWidget.settingsController.removeListener(_handleAppStateChanged);
      widget.settingsController.addListener(_handleAppStateChanged);
    }
    if (oldWidget.contentController != widget.contentController) {
      oldWidget.contentController.removeListener(_handleAppStateChanged);
      widget.contentController.addListener(_handleAppStateChanged);
      oldWidget.contentController.removeListener(_handleUpdateProgress);
      widget.contentController.addListener(_handleUpdateProgress);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.settingsController.removeListener(_handleAppStateChanged);
    widget.contentController.removeListener(_handleAppStateChanged);
    widget.contentController.removeListener(_handleUpdateProgress);
    super.dispose();
  }

  void _handleUpdateProgress() {
    final progress = widget.contentController.updateProgress;
    switch (progress.state) {
      case UpdateState.checking:
      case UpdateState.downloadingBundle:
      case UpdateState.downloadingMedia:
      case UpdateState.installing:
        _maybeShowUpdateDialog();
      case UpdateState.done:
      case UpdateState.error:
      case UpdateState.idle:
        break;
    }
  }

  bool _isDialogShowing = false;

  void _maybeShowUpdateDialog() {
    if (!mounted || _isDialogShowing) return;

    _isDialogShowing = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          UpdateProgressDialog(contentController: widget.contentController),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _syncContentLanguage();
  }

  @override
  Widget build(BuildContext context) {
    final localePreference = widget.settingsController.localePreference;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: localePreference.explicitLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        return AppLocale.resolveLocale(locale, supportedLocales);
      },
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: widget.settingsController.lastTab.routePath,
      onGenerateRoute: (settings) {
        return AppRouter.generateRoute(
          settings,
          widget.settingsController,
          widget.contentController,
        );
      },
    );
  }

  void _handleAppStateChanged() {
    _syncContentLanguage();
    if (mounted) {
      setState(() {});
    }
  }

  void _syncContentLanguage() {
    final languageCode = AppLocale.resolveLanguageCode(
      widget.settingsController.localePreference,
      WidgetsBinding.instance.platformDispatcher.locales,
    );
    widget.contentController.loadLanguage(languageCode);
  }
}
