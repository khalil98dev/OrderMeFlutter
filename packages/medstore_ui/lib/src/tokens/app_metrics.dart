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

/// Continuous, Apple-like corner radii.
abstract final class AppRadii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;

  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
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

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOutCubic;

  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}
