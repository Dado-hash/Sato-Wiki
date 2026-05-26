import 'data/content_bundle_errors.dart';
import 'domain/content_media.dart';
import 'domain/content_store.dart';
import '../search/search_index.dart';

final class AppContent {
  const AppContent({
    required this.store,
    required this.searchIndex,
    required this.mediaResolver,
    required this.warnings,
  });

  final ContentStore store;
  final SearchIndex searchIndex;
  final ContentMediaResolver mediaResolver;
  final List<ContentBundleWarning> warnings;
}
