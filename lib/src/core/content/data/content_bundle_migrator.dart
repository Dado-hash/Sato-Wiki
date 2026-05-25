import '../domain/content_models.dart';
import 'content_bundle_errors.dart';

abstract final class ContentBundleMigrator {
  static const currentSchemaVersion = 1;

  static ContentBundleMigrationResult migrate(JsonMap input) {
    final warnings = <ContentBundleWarning>[];
    final schemaVersion = input['schemaVersion'];

    if (schemaVersion == null) {
      warnings.add(
        const ContentBundleWarning(
          path: 'schemaVersion',
          message: 'Missing schemaVersion. Assuming 1.',
        ),
      );

      return ContentBundleMigrationResult(
        data: {...input, 'schemaVersion': 1},
        warnings: warnings,
      );
    }

    if (schemaVersion is! int) {
      throw const ContentBundleParseException(
        'schemaVersion must be an integer.',
      );
    }

    if (schemaVersion > currentSchemaVersion) {
      throw ContentBundleParseException(
        'Unsupported content schemaVersion $schemaVersion.',
      );
    }

    return ContentBundleMigrationResult(data: input, warnings: warnings);
  }
}

final class ContentBundleMigrationResult {
  const ContentBundleMigrationResult({
    required this.data,
    required this.warnings,
  });

  final JsonMap data;
  final List<ContentBundleWarning> warnings;
}
