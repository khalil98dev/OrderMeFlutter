import 'package:flutter/widgets.dart';

/// 8-point spacing.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Apple's minimum touch target.
  static const double minTouchTarget = 44;

  static const EdgeInsets screenMobile = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets screenDesktop = EdgeInsets.all(lg);
  static const EdgeInsets card = EdgeInsets.all(md);
}

/// Soft, generous corner radii.
abstract final class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
}

/// Soft, wide, low shadows: a surface lifts off the canvas without a hard edge. Light mode only; in
/// dark mode surfaces are told apart by their lighter grey and the hairline border.
abstract final class AppShadows {
  /// Cards and table frames at rest.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A101828), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0F101828), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// A card under the pointer, popovers, toasts.
  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x0F101828), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x1A101828), blurRadius: 28, offset: Offset(0, 12)),
  ];

  static List<BoxShadow> of(BuildContext context, List<BoxShadow> shadows) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark ? const [] : shadows;
}

/// Motion. Every animation goes through [of], so "reduce motion" turns them all off.
abstract final class AppDurations {
  static const Duration micro = Duration(milliseconds: 160);
  static const Duration selection = Duration(milliseconds: 260);
  static const Duration expand = Duration(milliseconds: 300);
  static const Duration screen = Duration(milliseconds: 350);

  /// An item flying into its target (add to cart).
  static const Duration flight = Duration(milliseconds: 650);

  /// The target's bounce when something lands in it.
  static const Duration bounce = Duration(milliseconds: 450);

  /// A target's smooth swell and settle (`AppBounceTarget.pop`).
  static const Duration pop = Duration(milliseconds: 520);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOutCubic;

  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
