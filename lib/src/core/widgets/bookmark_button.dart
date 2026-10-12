import 'package:flutter/material.dart';

import '../../generated/l10n/app_localizations.dart';
import '../settings/app_settings_scope.dart';
import 'round_icon_button.dart';

/// Toggles the bookmark for [contentId]. Hidden when no settings scope is above it.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({required this.contentId, super.key});

  final String contentId;

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.maybeOf(context);
    if (settings == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final saved = settings.isBookmarked(contentId);

    return RoundIconButton(
      icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      selected: saved,
      tooltip: saved ? l10n.removeBookmark : l10n.saveBookmark,
      onPressed: () => settings.toggleBookmark(contentId),
    );
  }
}
