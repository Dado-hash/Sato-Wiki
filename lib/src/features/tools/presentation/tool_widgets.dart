import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/content/domain/content_models.dart' as content;
import '../../../core/content/domain/content_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/sato_colors.dart';
import '../../../core/widgets/content_mappers.dart';
import '../../../core/widgets/related_links_grid.dart';
import '../../../core/widgets/section_title.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Shared pieces of the offline tools: input boxes, result cards, monospace
/// values and the wiki links at the foot of each tool.

/// Text box for what the user types into a tool.
///
/// Autocorrect, suggestions and keyboard learning are off, so what is typed
/// is not kept by the keyboard either.
class ToolTextField extends StatelessWidget {
  const ToolTextField({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.errorText,
    this.minLines = 1,
    this.maxLines = 1,
    this.monospace = false,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final int minLines;
  final int? maxLines;
  final bool monospace;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.tile),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      style: monospace
          ? toolMonoStyle(context)
          : textTheme.bodyLarge?.copyWith(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        errorMaxLines: 3,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }
}

/// Card with a small uppercase label and content below it.
class ToolResultCard extends StatelessWidget {
  const ToolResultCard({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

/// A monospace value that can be selected, with a copy button beside it.
class ToolCopyValue extends StatelessWidget {
  const ToolCopyValue({required this.value, super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SelectableText(value, style: toolMonoStyle(context))),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20),
          tooltip: l10n.toolsCopy,
          onPressed: () async {
            final messenger = ScaffoldMessenger.maybeOf(context);
            await Clipboard.setData(ClipboardData(text: value));
            messenger?.showSnackBar(SnackBar(content: Text(l10n.toolsCopied)));
          },
        ),
      ],
    );
  }
}

/// Monospace text for data: hashes, hex, scripts and numbers.
class ToolMonoBlock extends StatelessWidget {
  const ToolMonoBlock({required this.spans, super.key});

  final List<InlineSpan> spans;

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(style: toolMonoStyle(context), children: spans),
    );
  }
}

/// Label and value on one line, used for legends and summary rows.
class ToolKeyValue extends StatelessWidget {
  const ToolKeyValue({
    required this.label,
    required this.value,
    this.monospace = false,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final bool monospace;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 104, child: Text(label, style: textTheme.bodySmall)),
          Expanded(
            child: Text(
              value,
              style: monospace
                  ? toolMonoStyle(context)
                  : textTheme.bodyMedium?.copyWith(fontSize: 14),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.thumb),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: row,
      ),
    );
  }
}

/// Colour swatch, name and value of one part of a hex or address string.
class ToolLegendRow extends StatelessWidget {
  const ToolLegendRow({
    required this.color,
    required this.label,
    required this.value,
    super.key,
  });

  /// Null for parts that are not coloured in the string (no swatch fill).
  final Color? color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
                Text(value, style: toolMonoStyle(context, size: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft background colours for parts of hex data, cycled in order.
List<Color> toolFieldPalette(BuildContext context) {
  final sato = context.sato;

  return [sato.fieldAmber, sato.fieldBlue, sato.fieldGreen, sato.fieldViolet];
}

/// Locale tag for number formatting, such as `en` or `it`.
String toolLocale(BuildContext context) {
  return Localizations.localeOf(context).toLanguageTag();
}

/// Monospace text style for data, based on the body text size.
TextStyle toolMonoStyle(BuildContext context, {double size = 13}) {
  final colorScheme = Theme.of(context).colorScheme;

  return TextStyle(
    fontFamily: AppFonts.mono,
    fontSize: size,
    height: 1.55,
    color: colorScheme.onSurface,
  );
}

/// Wiki links for the tool. Ids whose entry is not in the loaded bundle are
/// left out, so a missing entry never shows a dead link.
class ToolWikiLinks extends StatelessWidget {
  const ToolWikiLinks({required this.store, required this.entryIds, super.key});

  final ContentStore store;
  final List<String> entryIds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loaded = [
      for (final id in entryIds)
        if (recordTitleFor(store, id) != null)
          content.RelatedContentLink(id: id),
    ];
    if (loaded.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title: l10n.toolsReadMore),
        const SizedBox(height: AppSpacing.md),
        RelatedLinksGrid(
          links: relatedLinks(
            loaded,
            store: store,
            onOpen: (route) => Navigator.of(context).pushNamed(route),
          ),
        ),
      ],
    );
  }
}
