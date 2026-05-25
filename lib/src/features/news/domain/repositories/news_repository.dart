import '../../../../core/content/domain/content_models.dart';

abstract interface class NewsRepository {
  Future<List<NewsArticle>> listArticles();

  Future<List<NewsArticle>> listArticlesByCategory(String category);

  Future<NewsArticle?> findArticleById(String id);
}
