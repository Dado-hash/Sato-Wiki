import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({required this.child, this.onTap, super.key});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);

    return Card(
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
