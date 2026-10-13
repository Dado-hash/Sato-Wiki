import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/localization/content_labels.dart';
import 'package:sato_wiki/src/generated/l10n/app_localizations.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations it;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    it = await AppLocalizations.delegate.load(const Locale('it'));
  });

  test('subcategory labels resolve in English and Italian', () {
    expect(contentSubcategoryLabel('nodes', en), 'Nodes');
    expect(contentSubcategoryLabel('nodes', it), 'Nodi');
    expect(contentSubcategoryLabel('software-wallets', en), 'Software wallets');
    expect(contentSubcategoryLabel('software-wallets', it), 'Software wallet');
    expect(
      contentSubcategoryLabel('developer-tools', it),
      'Librerie e strumenti per sviluppatori',
    );
    expect(contentSubcategoryLabel('seed-backups', en), 'Seed backups');
    expect(
      contentSubcategoryLabel('mining-hardware', it),
      'Hardware di mining',
    );
  });

  test('subcategory lookup ignores case and surrounding spaces', () {
    expect(contentSubcategoryLabel(' Lightning ', en), 'Lightning');
  });

  test('unknown subcategory falls back to capitalized words', () {
    expect(contentSubcategoryLabel('new-thing', en), 'New thing');
    expect(contentSubcategoryLabel('new-thing', it), 'New thing');
  });

  test('blank subcategory is returned unchanged', () {
    expect(contentSubcategoryLabel('', en), '');
  });

  test('software and hardware category labels resolve', () {
    expect(contentCategoryLabel('software', en), 'Software');
    expect(contentCategoryLabel('hardware', it), 'Hardware');
  });

  test('unknown category keeps the existing fallback', () {
    expect(contentCategoryLabel('some-new-category', en), 'Some new category');
  });
}
