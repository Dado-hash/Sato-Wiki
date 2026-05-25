import '../../../../core/content/domain/content_models.dart';

abstract interface class CodeRepository {
  Future<List<Bip>> listBips();

  Future<List<Bip>> listBipsByStatus(BipStatus status);

  Future<Bip?> findBipByNumber(int number);

  Future<List<ReleaseNote>> listReleaseNotes();

  Future<List<ReleaseNote>> listReleaseNotesByProject(String project);

  Future<ReleaseNote?> findReleaseNoteById(String id);
}
