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
    'software' => l10n.categorySoftware,
    'hardware' => l10n.categoryHardware,
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

/// Localized label for a wiki subcategory key such as `software-wallets`.
///
/// Unknown keys use the same fallback as [contentCategoryLabel].
String contentSubcategoryLabel(String subcategory, AppLocalizations l10n) {
  final key = subcategory.trim().toLowerCase();

  return switch (key) {
    'nodes' => l10n.subcategoryNodes,
    'software-wallets' => l10n.subcategorySoftwareWallets,
    'lightning' => l10n.subcategoryLightning,
    'servers' => l10n.subcategoryServers,
    'node-systems' => l10n.subcategoryNodeSystems,
    'mining-software' => l10n.subcategoryMiningSoftware,
    'developer-tools' => l10n.subcategoryDeveloperTools,
    'hardware-wallets' => l10n.subcategoryHardwareWallets,
    'seed-backups' => l10n.subcategorySeedBackups,
    'mining-hardware' => l10n.subcategoryMiningHardware,
    'node-hardware' => l10n.subcategoryNodeHardware,
    _ when key.isEmpty => subcategory,
    _ => key[0].toUpperCase() + key.substring(1).replaceAll('-', ' '),
  };
}

/// Source path of the first Markdown image in [markdown], or null.
String? firstMarkdownImageSource(String markdown) {
  final match = _markdownImage.firstMatch(markdown);

  return match?.group(1);
}

final _markdownImage = RegExp(r'!\[[^\]]*\]\(\s*([^)\s]+)');
