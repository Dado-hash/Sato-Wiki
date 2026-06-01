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
      BipStatus.draft => l10n.statusDraft,
      BipStatus.complete => l10n.statusComplete,
      BipStatus.deployed => l10n.statusDeployed,
      BipStatus.closed => l10n.statusClosed,
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
