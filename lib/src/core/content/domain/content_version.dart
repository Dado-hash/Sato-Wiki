/// Content versions are dotted numbers such as `2026.06.20.071041`. They are
/// also used as directory names for cached media, so anything else is refused.
final RegExp _contentVersionPattern = RegExp(r'^\d+(\.\d+)*$');

bool isValidContentVersion(String version) {
  return _contentVersionPattern.hasMatch(version);
}

/// Returns true when [candidate] is newer than [current].
///
/// Numeric versions are compared part by part (missing parts count as 0).
/// If either version is not numeric, the strings are compared instead.
bool isNewerContentVersion(String candidate, String current) {
  final candidateParts = _versionParts(candidate);
  final currentParts = _versionParts(current);
  if (candidateParts != null && currentParts != null) {
    final length = candidateParts.length > currentParts.length
        ? candidateParts.length
        : currentParts.length;
    for (var i = 0; i < length; i++) {
      final candidateValue = i < candidateParts.length ? candidateParts[i] : 0;
      final currentValue = i < currentParts.length ? currentParts[i] : 0;
      if (candidateValue != currentValue) {
        return candidateValue > currentValue;
      }
    }

    return false;
  }

  return candidate.compareTo(current) > 0;
}

List<int>? _versionParts(String version) {
  final parts = version.split('.');
  final values = <int>[];
  for (final part in parts) {
    final value = int.tryParse(part);
    if (value == null) {
      return null;
    }
    values.add(value);
  }

  return values;
}
