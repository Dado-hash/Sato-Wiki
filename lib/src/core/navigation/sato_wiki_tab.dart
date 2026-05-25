enum SatoWikiTab {
  wiki('/wiki', 'Wiki'),
  news('/news', 'News'),
  history('/history', 'History'),
  code('/code', 'Code');

  const SatoWikiTab(this.routePath, this.label);

  final String routePath;
  final String label;

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
