import '../../generated/l10n/app_localizations.dart';

/// Localized label for a content category key from a bundle.
///
/// Covers wiki, news, history and BIP categories. Unknown keys are shown
/// with dashes as spaces and a capital first letter.
String contentCategoryLabel(String category, AppLocalizations l10n) {
  final key = category.trim().toLowerCase();

  return switch (key) {
    'protocol' => l10n.categoryProtocol,
    'cryptography' => l10n.categoryCryptography,
    'lightning network' => l10n.categoryLightningNetwork,
    'economics' => l10n.categoryEconomics,
    'market' => l10n.market,
    'regulatory' => l10n.regulatory,
    'culture' => l10n.culture,
    'development' => l10n.development,
    'community' => l10n.community,
    'origin' => l10n.categoryOrigin,
    'security' => l10n.categorySecurity,
    'adoption' => l10n.categoryAdoption,
    'regulation' => l10n.categoryRegulation,
    'consensus' => l10n.categoryConsensus,
    'applications' => l10n.categoryApplications,
    'peer-services' => l10n.categoryPeerServices,
    'informational' => l10n.categoryInformational,
    'process' => l10n.categoryProcess,
    'api-rpc' => l10n.categoryApiRpc,
    'specification' => l10n.categorySpecification,
    _ when key.isEmpty => category,
    _ => key[0].toUpperCase() + key.substring(1).replaceAll('-', ' '),
  };
}

/// Source path of the first Markdown image in [markdown], or null.
String? firstMarkdownImageSource(String markdown) {
  final match = _markdownImage.firstMatch(markdown);

  return match?.group(1);
}

final _markdownImage = RegExp(r'!\[[^\]]*\]\(\s*([^)\s]+)');
