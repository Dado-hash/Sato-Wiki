import 'package:flutter/widgets.dart';

import '../content/domain/content_media.dart';

class ContentMediaScope extends InheritedWidget {
  const ContentMediaScope({
    required this.resolver,
    required super.child,
    super.key,
  });

  final ContentMediaResolver resolver;

  static ContentMediaResolver? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ContentMediaScope>()
        ?.resolver;
  }

  @override
  bool updateShouldNotify(ContentMediaScope oldWidget) {
    return resolver != oldWidget.resolver;
  }
}
