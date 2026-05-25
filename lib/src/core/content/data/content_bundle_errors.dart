final class ContentBundleWarning {
  const ContentBundleWarning({required this.path, required this.message});

  final String path;
  final String message;
}

final class ContentBundleParseException implements Exception {
  const ContentBundleParseException(this.message);

  final String message;

  @override
  String toString() => 'ContentBundleParseException: $message';
}
