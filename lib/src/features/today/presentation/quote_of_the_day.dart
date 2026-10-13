import '../../../core/content/domain/content_models.dart';

/// Day zero of the quote rotation: the Bitcoin genesis block date.
final DateTime _genesisDay = DateTime.utc(2009, 1, 3);

/// The quote shown on [day], the same on every device.
///
/// Quotes are sorted by id and indexed by the number of days since the genesis
/// block, modulo the number of quotes, so the rotation wraps around. Only the
/// calendar date of [day] is used. Returns null when there are no quotes.
Quote? quoteOfTheDay(List<Quote> quotes, DateTime day) {
  if (quotes.isEmpty) {
    return null;
  }

  final sorted = [...quotes]..sort((a, b) => a.id.compareTo(b.id));
  final calendarDay = DateTime.utc(day.year, day.month, day.day);
  final daysSinceGenesis = calendarDay.difference(_genesisDay).inDays;

  return sorted[daysSinceGenesis % sorted.length];
}
