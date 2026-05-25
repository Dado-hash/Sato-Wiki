import '../content/reading_level.dart';
import '../content/domain/content_models.dart';
import '../search/search_index.dart';
import '../../generated/l10n/app_localizations.dart';

extension ReadingLevelLabels on ReadingLevel {
  String label(AppLocalizations l10n) {
    return switch (this) {
      ReadingLevel.base => l10n.readingLevelBase,
      ReadingLevel.medium => l10n.readingLevelMedium,
      ReadingLevel.advanced => l10n.readingLevelAdvanced,
    };
  }
}

extension BipStatusLabels on BipStatus {
  String label(AppLocalizations l10n) {
    return switch (this) {
      BipStatus.active => l10n.statusActive,
      BipStatus.finalStatus => l10n.statusFinal,
      BipStatus.draft => l10n.statusDraft,
      BipStatus.proposed => l10n.statusProposed,
      BipStatus.withdrawn => l10n.statusWithdrawn,
      BipStatus.rejected => l10n.statusRejected,
    };
  }
}

extension SearchSectionLabels on SearchSection {
  String label(AppLocalizations l10n) {
    return switch (this) {
      SearchSection.wiki => l10n.wikiTab,
      SearchSection.news => l10n.newsTab,
      SearchSection.history => l10n.historyTab,
      SearchSection.code => l10n.codeTab,
    };
  }
}
