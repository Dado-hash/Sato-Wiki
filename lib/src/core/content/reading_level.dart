enum ReadingLevel {
  base('base', 'Base'),
  medium('medium', 'Medio'),
  advanced('advanced', 'Avanzato');

  const ReadingLevel(this.storageValue, this.label);

  final String storageValue;
  final String label;

  static ReadingLevel? fromStorageValue(String? value) {
    for (final level in ReadingLevel.values) {
      if (level.storageValue == value) {
        return level;
      }
    }

    return null;
  }
}
