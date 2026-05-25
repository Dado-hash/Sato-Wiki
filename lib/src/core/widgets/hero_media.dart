import 'package:flutter/material.dart';

class HeroMedia extends StatelessWidget {
  const HeroMedia({
    required this.icon,
    required this.label,
    this.aspectRatio = 21 / 9,
    super.key,
  });

  final IconData icon;
  final String label;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: label,
      image: true,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _HeroMediaPainter(colorScheme: colorScheme)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: colorScheme.primary, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMediaPainter extends CustomPainter {
  const _HeroMediaPainter({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    const gap = 28.0;

    for (var x = 0.0; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        gridPaint,
      );
    }

    final nodePaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    for (var index = 0; index < 9; index++) {
      final dx = size.width * ((index * 17 % 83) / 100);
      final dy = size.height * ((index * 29 % 71) / 100);
      canvas.drawCircle(Offset(dx, dy), 3.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroMediaPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme;
  }
}
