enum ReadingLevel {
  base('base'),
  medium('medium'),
  advanced('advanced');

  const ReadingLevel(this.storageValue);

  final String storageValue;

  static ReadingLevel? fromStorageValue(String? value) {
    for (final level in ReadingLevel.values) {
      if (level.storageValue == value) {
        return level;
      }
    }

    return null;
  }
}
