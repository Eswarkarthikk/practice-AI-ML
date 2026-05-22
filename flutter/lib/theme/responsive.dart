import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double scale(BuildContext context, double size, {double factor = 1.35}) {
    if (isTablet(context)) {
      return size * factor;
    }
    return size;
  }

  static Widget constrained(BuildContext context, Widget child) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 800) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: child,
        ),
      );
    }
    return child;
  }
}

extension ResponsiveExtension on num {
  double r(BuildContext context, {double factor = 1.35}) {
    return Responsive.scale(context, toDouble(), factor: factor);
  }
}
