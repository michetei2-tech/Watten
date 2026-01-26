import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BavarianBackgroundPainter(),
      child: SizedBox.expand(child: child),
    );
  }
}

class BavarianBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlue = Paint()
      ..color = const Color(0xFFB3D9FF).withOpacity(0.35);

    const double diamondSize = 60;

    for (double y = -diamondSize; y < size.height + diamondSize; y += diamondSize) {
      for (double x = -diamondSize; x < size.width + diamondSize; x += diamondSize) {
        final path = Path();
        path.moveTo(x, y + diamondSize / 2);
        path.lineTo(x + diamondSize / 2, y);
        path.lineTo(x + diamondSize, y + diamondSize / 2);
        path.lineTo(x + diamondSize / 2, y + diamondSize);
        path.close();

        canvas.drawPath(path, paintBlue);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
