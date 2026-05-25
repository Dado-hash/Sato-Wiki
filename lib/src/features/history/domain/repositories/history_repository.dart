import '../../../../core/content/domain/content_models.dart';

abstract interface class HistoryRepository {
  Future<List<HistoryEvent>> listEvents();

  Future<List<HistoryEvent>> listEventsByCategory(String category);

  Future<List<HistoryEvent>> listEventsOnMonthDay(int month, int day);

  Future<HistoryEvent?> findEventById(String id);
}
