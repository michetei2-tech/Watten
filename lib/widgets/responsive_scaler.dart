import 'package:flutter/material.dart';

class ResponsiveScaler extends StatelessWidget {
  final Widget child;

  const ResponsiveScaler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const baseWidth = 390.0; // iPhone 12/13/14 Standardbreite

    double scale = size.width / baseWidth;

    // WICHTIG: Nie größer skalieren als 1.0
    if (scale > 1.0) scale = 1.0;

    return Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}
