import '../../../core/content/domain/content_models.dart';
import '../../../core/content/domain/content_store.dart';
import '../../../core/navigation/content_routes.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/widgets/content_mappers.dart';

/// Reading progress from which an entry counts as read.
const double learnReadThreshold = AppSettingsController.finishedProgress;

/// Whether a stored reading progress means the entry was finished.
bool isLearnEntryRead(double progress) => progress >= learnReadThreshold;

/// One step of a path whose id matches a loaded record.
final class ResolvedPathStep {
  const ResolvedPathStep({
    required this.number,
    required this.id,
    required this.title,
    required this.note,
    required this.isRead,
    required this.route,
  });

  /// 1-based position among the resolved steps.
  final int number;
  final String id;
  final String title;
  final String note;
  final bool isRead;

  /// Screen for the record, or null when the id has no detail screen.
  final String? route;
}

/// A path with its steps resolved against the loaded content.
final class LearningPathProgress {
  const LearningPathProgress({required this.path, required this.steps});

  /// Builds the resolved steps in path order. Steps whose id matches no loaded
  /// record are skipped and do not count towards the total.
  factory LearningPathProgress.of(
    LearningPath path,
    ContentStore store, {
    required double Function(String contentId) progressFor,
  }) {
    final resolved = <ResolvedPathStep>[];
    for (final step in path.steps) {
      final title = recordTitleFor(store, step.id);
      if (title == null) {
        continue;
      }
      resolved.add(
        ResolvedPathStep(
          number: resolved.length + 1,
          id: step.id,
          title: title,
          note: step.note,
          isRead: isLearnEntryRead(progressFor(step.id)),
          route: routeForContentId(step.id),
        ),
      );
    }

    return LearningPathProgress(path: path, steps: resolved);
  }

  final LearningPath path;
  final List<ResolvedPathStep> steps;

  int get total => steps.length;

  int get readCount => steps.where((step) => step.isRead).length;

  /// Fraction of resolved steps read, from 0 to 1.
  double get fraction => total == 0 ? 0 : readCount / total;

  /// First step in path order that is not read yet, or null when all are.
  ResolvedPathStep? get nextUnread =>
      steps.where((step) => !step.isRead).firstOrNull;
}

/// Whether the record with [id] is read by scrolling its screen. Wiki entries
/// and news articles track scroll progress; the other records are short and
/// count as read once opened from a path.
bool tracksScrollProgress(String id) =>
    id.startsWith('wiki.') || id.startsWith('news.');
