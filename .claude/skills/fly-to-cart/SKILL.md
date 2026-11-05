---
name: fly-to-cart
description: Build the Flutter "add to cart" flight animation - a copy of the product image flies along a curved arc from its tile into the cart icon, shrinking, and the cart bounces when it lands. GlobalKey + root Overlay + Offset.lerp twice (quadratic Bezier), no package. Use when the user asks for a fly-to-cart / add-to-basket / "product flies into the cart" animation, an item flying to a badge, tab or icon, a curved-path Overlay animation, or a bounce on the target.
---

# Fly to cart

The product flies along a curve, drops into the cart, and the cart bounces. Pure Flutter: a
`GlobalKey` to find the cart, the root `Overlay` to draw above everything, and `Offset.lerp` applied
twice to bend the path. Based on moza.flutter's reel (instagram.com/p/DfUdja5hz5j).

**In this project it already exists**, exported from `package:medstore_ui/medstore_ui.dart`. Use it;
do not rebuild it:

- `packages/medstore_ui/lib/src/components/motion/app_bounce_target.dart`: `AppBounceTarget`, wraps the cart icon. Its state's `bounce()` plays grow/squash/settle.
- `packages/medstore_ui/lib/src/components/motion/fly_to_target.dart`: `flyToTarget(sourceContext, target:, child:)`, the flight. Completes when it lands.
- Tokens `AppDurations.flight` (650 ms) and `AppDurations.bounce` (450 ms).
- Gallery demo: `packages/medstore_ui/example/lib/sections/motion_section.dart`.
- Tests: `packages/medstore_ui/test/motion_test.dart` (curve, landing, bounce, 5 fast flights, reduce motion, target gone mid-flight).

`reference/` keeps a standalone copy for another Flutter project; the files in `medstore_ui` are the source of truth here.

## How it works

1. **Find both ends.** The cart has a `GlobalKey<AppBounceTargetState>`. The flyer starts at the
   `RenderBox` of the context it was given. Take both centres with
   `localToGlobal(..., ancestor: overlayBox)`, relative to the overlay and not the screen, so it is
   right inside sheets, split views and the desktop sidebar layout. Measure synchronously, before any `await`.
2. **Bend the path.** A straight `Offset.lerp(start, end, t)` looks robotic. Add a control point
   above the higher end, halfway across, and lerp twice (de Casteljau = a quadratic Bezier):
   ```dart
   final a = Offset.lerp(start, control, t)!;
   final b = Offset.lerp(control, end, t)!;
   final point = Offset.lerp(a, b, t)!;
   ```
   Raise `arcHeight` for a higher jump; use `math.min(start.dy, end.dy) - arcHeight` so it rises even when the cart is above the tile.
3. **Draw it in the root overlay.** `Overlay.maybeOf(context, rootOverlay: true)`: above the tab bar and app bar, outside any list clipping.
   The `OverlayState` is the `vsync`. Wrap the flyer in `IgnorePointer` so it never steals a tap.
   Shrink it (`1 -> 0.3`) and fade only in the last 15 % so it looks like it went *into* the cart.
4. **Land and bounce.** After the flight, `target.currentState?.bounce()`. A `TweenSequence`
   `1 -> 1.25 -> 0.9 -> 1.05 -> 1` with `forward(from: 0)`, so a second item landing mid-bounce restarts it.

## The remove() trap

An `OverlayEntry` must be removed **exactly once**:

- removed twice (a status listener *and* `dispose`, or two flights sharing one entry) -> assertion / crash;
- never removed (an exception or a popped screen skipped the cleanup) -> a frozen image stuck over the app forever.

So: one owner, one place, `finally`. Each flight creates its own entry and controller, and disposes everything itself:

```dart
overlay.insert(entry);
try {
  await controller.forward().orCancel;
} on TickerCanceled {
  // screen went away mid-flight
} finally {
  entry.remove();
  entry.dispose();
  controller.dispose();
}
```

Never keep the entry in a field, and never remove it from a `StatusListener`.

## Rules for this project

- **State first, animation second.** Call the Cubit (`cubit.add(product)`) *before* `flyToTarget`,
  and don't make anything wait on it. The animation is decoration: it must never decide whether the item was added.
- **Reduce motion.** Durations go through `AppDurations.of(context, ...)`; with reduced motion there is no flight and no bounce, only the count change.
  If the duration is used in several places, add it to `AppDurations` in
  `packages/medstore_ui/lib/src/tokens/app_metrics.dart` (for example `flight = 650 ms`) instead of hard-coding it.
- **Pass the right context.** `sourceContext` must be the *cover's* context, not the screen's or the
  whole tile's, or the flight starts from the wrong place. The clean way: the tile is a small
  `StatefulWidget` with `final _coverKey = GlobalKey();` on the cover, and passes `_coverKey.currentContext`.
  A `Builder` only works if it wraps the cover alone.
- **Fire and forget with `unawaited(...)`.** The lints (`unawaited_futures`) reject a bare `flyToTarget(...)` call.
- **Off screen = skip.** If either end has no attached `RenderBox` (cart scrolled away, different tab
  shown), `flyToTarget` returns immediately. Keep that behaviour.
- **RTL.** Positions are measured, never computed from `left`/`right`, so Arabic layouts need no special case. Check it in Arabic anyway.
- **Placement in the design system** (see the readable-reusable-UI rule): put the two files in
  `packages/medstore_ui/lib/src/components/motion/` (the reference imports `../../tokens/...` from
  there), one widget per file, documented, and export both from `lib/medstore_ui.dart` under a `// Motion` heading.
  No colours inside: the flyer is whatever widget the caller passes, and the cart icon keeps its own `AppTone`.
- **Gallery first.** Add a section to `packages/medstore_ui/example/lib/sections/` with a product tile and a cart icon.
  Check in the gallery that it flies, lands and bounces, that rapid taps (several flights at once) leave no ghost,
  and that it behaves with reduced motion and in Arabic. Only then use it in `apps/medstore_teacher`.

## Usage

```dart
final _cartKey = GlobalKey<AppBounceTargetState>();

// In the navigation bar / page header:
AppBounceTarget(key: _cartKey, child: const Icon(CupertinoIcons.cart));

// In the product tile's State:
final _coverKey = GlobalKey();

void _add() {
  context.read<CartCubit>().add(widget.product);          // state first
  final cover = _coverKey.currentContext;
  if (cover == null) return;
  unawaited(flyToTarget(cover, target: widget.cartKey, child: ProductCover(widget.product)));
}

// build: ProductCover(key: _coverKey, ...) ... AppButton(label: strings.addToCart, onPressed: _add)
```

If the cart is in a different widget subtree from the tiles (a shell route's tab bar), expose the key
from the shell (or register it in `get_it`) rather than creating a second one: a `GlobalKey` must be
attached to exactly one widget.

## Verify

1. `flutter analyze` in `packages/medstore_ui` and `flutter test test/motion_test.dart` -> no issues, all pass.
2. Gallery: tap once (arc, shrink, bounce), tap 5x fast (5 flights, no leftover image), turn on reduce motion (count updates, nothing flies), switch to Arabic.
3. Pop the screen mid-flight: no exception in the console, no image left over.
