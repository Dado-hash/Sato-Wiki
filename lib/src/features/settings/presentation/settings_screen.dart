import 'package:flutter/material.dart';

import '../../../core/content/application/app_content_controller.dart';
import '../../../core/content/reading_level.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/localization/localized_labels.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/theme_preference.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/detail_scaffold.dart';
import '../../../core/widgets/sato_group_card.dart';
import '../../../core/widgets/sato_segmented_control.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../generated/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.settings,
    required this.content,
    super.key,
  });

  final AppSettingsController settings;
  final AppContentController content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([settings, content]),
      builder: (context, _) {
        return DetailScaffold(
          title: l10n.settingsTitle,
          children: [
            const SizedBox(height: AppSpacing.sm),
            _SettingsGroup(
              label: l10n.settingsReading,
              child: _ReadingCard(settings: settings),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SettingsGroup(
              label: l10n.settingsAppearance,
              child: _AppearanceCard(settings: settings),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SettingsGroup(
              label: l10n.languageTitle,
              child: _LanguageCard(settings: settings),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SettingsGroup(
              label: l10n.bookmarks,
              child: SatoGroupCard(
                children: [
                  _TappableRow(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.bookmarks),
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.bookmarks,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${settings.bookmarks.length}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ChevronIcon(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SettingsGroup(
              label: l10n.settingsContent,
              child: _ContentCard(content: content),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SettingsGroup(
              label: l10n.settingsAbout,
              child: SatoGroupCard(
                children: [
                  _TappableRow(
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: l10n.appTitle,
                    ),
                    children: [
                      Expanded(
                        child: Text(
                          l10n.openSourceLicenses,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _ChevronIcon(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SatoGroupCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.defaultLevel, style: textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
              SatoSegmentedControl<ReadingLevel>(
                items: ReadingLevel.values,
                selected: settings.readingLevel,
                labelFor: (level) => level.label(l10n),
                onChanged: settings.setReadingLevel,
                raisedTrack: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.textSize, style: textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
              SatoSegmentedControl<double>(
                items: AppSettingsController.readerTextScales,
                selected: settings.readerTextScale,
                labelFor: (scale) => '${(scale * 100).round()}%',
                onChanged: settings.setReaderTextScale,
                raisedTrack: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SatoGroupCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
              SatoSegmentedControl<ThemePreference>(
                items: ThemePreference.values,
                selected: settings.themePreference,
                labelFor: (preference) => switch (preference) {
                  ThemePreference.system => l10n.themeSystem,
                  ThemePreference.light => l10n.themeLight,
                  ThemePreference.dark => l10n.themeDark,
                },
                onChanged: settings.setThemePreference,
                raisedTrack: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = <(AppLocalePreference, String)>[
      (const AppLocalePreference.system(), l10n.languageSystemDefault),
      (const AppLocalePreference.language('en'), l10n.languageEnglish),
      (const AppLocalePreference.language('it'), l10n.languageItalian),
    ];

    return SatoGroupCard(
      children: [
        for (final (preference, label) in options)
          _TappableRow(
            selected: settings.localePreference == preference,
            onTap: () => settings.setLocalePreference(preference),
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (settings.localePreference == preference)
                Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.content});

  final AppContentController content;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sato = context.sato;
    final state = content.updateProgress.state;
    final isBusy = switch (state) {
      UpdateState.checking ||
      UpdateState.downloadingBundle ||
      UpdateState.downloadingMedia ||
      UpdateState.installing => true,
      _ => false,
    };
    final hasError = state == UpdateState.error;

    return SatoGroupCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.contentVersion, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      content.content.store.bundle.version,
                      style: textTheme.labelMedium,
                    ),
                    if (hasError) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.contentUpdateError,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (isBusy)
                StatusPill(label: l10n.updating, color: sato.statusDraft)
              else if (!hasError)
                StatusPill(label: l10n.upToDate, color: sato.statusDeployed),
            ],
          ),
        ),
        _TappableRow(
          onTap: isBusy ? null : () => content.checkForUpdates(),
          children: [
            Expanded(
              child: Text(
                l10n.checkForUpdates,
                style: textTheme.titleSmall?.copyWith(
                  color: isBusy
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Full-width row with a 52px minimum height, used inside [SatoGroupCard].
class _TappableRow extends StatelessWidget {
  const _TappableRow({
    required this.onTap,
    required this.children,
    this.selected,
  });

  final VoidCallback? onTap;
  final List<Widget> children;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.centerLeft,
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
