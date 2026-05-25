import '../../../../core/content/domain/content_models.dart';

abstract interface class WikiRepository {
  Future<List<WikiEntry>> listEntries();

  Future<List<WikiEntry>> listEntriesByCategory(String category);

  Future<WikiEntry?> findEntryById(String id);
}
