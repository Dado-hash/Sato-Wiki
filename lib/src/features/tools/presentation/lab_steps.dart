import '../../../generated/l10n/app_localizations.dart';

/// Steps of the blockchain lab. The last one is optional.
const int labStepCount = 7;

/// Title of lab [step] from 1 to [labStepCount].
String labStepTitle(AppLocalizations l10n, int step) {
  return switch (step) {
    1 => l10n.labStepTitle1,
    2 => l10n.labStepTitle2,
    3 => l10n.labStepTitle3,
    4 => l10n.labStepTitle4,
    5 => l10n.labStepTitle5,
    6 => l10n.labStepTitle6,
    _ => l10n.labStepTitle7,
  };
}

/// One-line description of lab [step], shown on the index and the step.
String labStepDescription(AppLocalizations l10n, int step) {
  return switch (step) {
    1 => l10n.labStepDesc1,
    2 => l10n.labStepDesc2,
    3 => l10n.labStepDesc3,
    4 => l10n.labStepDesc4,
    5 => l10n.labStepDesc5,
    6 => l10n.labStepDesc6,
    _ => l10n.labStepDesc7,
  };
}

/// The "In Bitcoin it is different" text that ends lab [step].
String labStepDifference(AppLocalizations l10n, int step) {
  return switch (step) {
    1 => l10n.labDiff1,
    2 => l10n.labDiff2,
    3 => l10n.labDiff3,
    4 => l10n.labDiff4,
    5 => l10n.labDiff5,
    6 => l10n.labDiff6,
    _ => l10n.labDiff7,
  };
}

/// Wiki entries that explain lab [step]. Missing entries are left out by the links.
List<String> labStepWikiIds(int step) {
  return switch (step) {
    1 => const ['wiki.hash-functions', 'wiki.sha-256'],
    2 => const ['wiki.proof-of-work', 'wiki.mining'],
    3 => const ['wiki.blockchain', 'wiki.blocks'],
    4 => const ['wiki.peer-to-peer-network', 'wiki.full-nodes'],
    5 => const ['wiki.transactions', 'wiki.digital-signatures'],
    6 => const ['wiki.coinbase-transaction', 'wiki.block-subsidy'],
    _ => const ['wiki.block-header', 'wiki.difficulty-adjustment'],
  };
}

/// Leading zero characters that a toy block hash needs in the lab.
const int labToyDifficulty = 4;
