import 'package:flutter_test/flutter_test.dart';

import 'package:sato_wiki/src/core/content/domain/content_models.dart';
import 'package:sato_wiki/src/features/today/presentation/quote_of_the_day.dart';

void main() {
  // Given out of id order on purpose: the choice must sort by id.
  final quotes = [_quote('quote.b'), _quote('quote.c'), _quote('quote.a')];

  test('the same calendar day gives the same quote at any time', () {
    final morning = quoteOfTheDay(quotes, DateTime(2026, 10, 13, 0, 5));
    final evening = quoteOfTheDay(quotes, DateTime(2026, 10, 13, 23, 59));
    final utc = quoteOfTheDay(quotes, DateTime.utc(2026, 10, 13, 12));

    expect(morning?.id, 'quote.a');
    expect(evening?.id, morning?.id);
    expect(utc?.id, morning?.id);
  });

  test('the next day shows the next quote in id order', () {
    // 2026-10-13 is 6492 days after 2009-01-03, and 6492 % 3 == 0.
    expect(quoteOfTheDay(quotes, DateTime(2026, 10, 13))?.id, 'quote.a');
    expect(quoteOfTheDay(quotes, DateTime(2026, 10, 14))?.id, 'quote.b');
    expect(quoteOfTheDay(quotes, DateTime(2026, 10, 15))?.id, 'quote.c');
  });

  test('the rotation wraps around after the last quote', () {
    // Three quotes: the fourth day after the first one is the first quote.
    expect(quoteOfTheDay(quotes, DateTime(2026, 10, 16))?.id, 'quote.a');
  });

  test('the genesis day shows the first quote', () {
    expect(quoteOfTheDay(quotes, DateTime.utc(2009, 1, 3))?.id, 'quote.a');
    expect(quoteOfTheDay(quotes, DateTime.utc(2009, 1, 4))?.id, 'quote.b');
  });

  test('days before the genesis block still pick a valid quote', () {
    expect(quoteOfTheDay(quotes, DateTime.utc(2009, 1, 2))?.id, 'quote.c');
  });

  test('no quotes gives no quote of the day', () {
    expect(quoteOfTheDay(const [], DateTime(2026, 10, 13)), isNull);
  });
}

Quote _quote(String id) {
  return Quote(
    id: id,
    slug: id.replaceFirst('quote.', ''),
    language: 'en',
    text: 'Text of $id.',
    author: 'Author',
    date: DateTime.utc(2008, 10, 31),
    sourceTitle: 'Source',
    sourceUrl: Uri.parse('https://example.com/source'),
    related: const [],
    updatedAt: DateTime.utc(2026, 5, 25),
  );
}
