import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  static const mobile = 600.0;
  static const tablet = 840.0;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobile) return 12;
    if (width < 1100) return 20;
    return 28;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;
}
