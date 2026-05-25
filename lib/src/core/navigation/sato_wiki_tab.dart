enum SatoWikiTab {
  wiki('/wiki'),
  news('/news'),
  history('/history'),
  code('/code');

  const SatoWikiTab(this.routePath);

  final String routePath;

  static SatoWikiTab fromIndex(int index) {
    return SatoWikiTab.values[index];
  }

  static SatoWikiTab? fromRoutePath(String? routePath) {
    for (final tab in SatoWikiTab.values) {
      if (tab.routePath == routePath) {
        return tab;
      }
    }

    return null;
  }
}
