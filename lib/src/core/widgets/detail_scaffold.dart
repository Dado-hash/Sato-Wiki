import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'round_icon_button.dart';
import 'sato_progress_bar.dart';

/// Pushed screen: back button row, optional reading progress, scrolling body.
class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    required this.children,
    this.actions = const [],
    this.title,
    this.progress,
    this.controller,
    super.key,
  });

  final List<Widget> children;
  final List<Widget> actions;
  final String? title;

  /// Reading progress from 0 to 1. Hidden when null.
  final double? progress;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final mediaPadding = MediaQuery.paddingOf(context);
    final currentProgress = progress;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                8,
                AppSpacing.gutter,
                0,
              ),
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  if (title != null) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title!,
                        style: textTheme.headlineMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),
                  for (final action in actions) ...[
                    const SizedBox(width: AppSpacing.sm),
                    action,
                  ],
                ],
              ),
            ),
            if (currentProgress != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.lg,
                  AppSpacing.gutter,
                  0,
                ),
                child: SatoProgressBar(
                  value: currentProgress,
                  height: 3,
                  semanticLabel: l10n.readPercent(
                    (currentProgress * 100).round(),
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                  AppSpacing.gutter,
                  32 + mediaPadding.bottom,
                ),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
