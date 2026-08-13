import 'package:flutter/material.dart';

const double mobileBreakpoint = 600;
const double tabletBreakpoint = 900;
const double desktopBreakpoint = 1200;
const double largeDesktopBreakpoint = 1440;

class Responsive extends StatelessWidget {
  final Widget mobileScreen;
  final Widget? tabletScreen;
  final Widget? desktopScreen;
  final Widget? largeDesktopScreen;

  const Responsive({
    super.key,
    required this.mobileScreen,
    this.tabletScreen,
    this.desktopScreen,
    this.largeDesktopScreen,
  });

  static bool isMobileScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTabletScreen(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktopScreen(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= desktopBreakpoint && width < largeDesktopBreakpoint;
  }

  static bool isLargeDesktopScreen(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= largeDesktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        if (width >= largeDesktopBreakpoint) {
          return largeDesktopScreen ??
              desktopScreen ??
              tabletScreen ??
              mobileScreen;
        } else if (width >= desktopBreakpoint) {
          return desktopScreen ?? tabletScreen ?? mobileScreen;
        } else if (width >= tabletBreakpoint) {
          return tabletScreen ?? mobileScreen;
        } else {
          return mobileScreen;
        }
      },
    );
  }
}
