import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;

import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_metrics.dart';
import '../../tokens/app_typography.dart';
import '../display/app_logo.dart';

class AppSidebarItem {
  const AppSidebarItem({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.section,
    this.badge = 0,
    this.color,
  });

  final String label;
  final IconData icon;
  final IconData? activeIcon;

  /// The color of the item's icon tile, as in macOS System Settings: a white glyph on a small rounded
  /// square of this color. Use Apple's system colors (`CupertinoColors.systemBlue`…); null draws the
  /// bare icon.
  final Color? color;

  /// Items with the same section are grouped under its title.
  final String? section;

  /// A count shown on the item (unread notifications). Hidden at zero; when it goes up the pill pops
  /// and the icon rings.
  final int badge;
}

/// macOS-style sidebar for the desktop app: sections, colored icon tiles, a blue selection, and a
/// collapse button that shrinks it to an icon rail.
///
/// Direction-aware: the border and the collapse animation sit on the *end* side, so in Arabic the
/// sidebar is on the right and everything mirrors.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.title,
    required this.subtitle,
    required this.collapsed,
    required this.onToggleCollapsed,
    required this.toggleLabel,
    this.footer,
  });

  static const double expandedWidth = 256;
  static const double collapsedWidth = 72;

  // Below this width the content switches to the compact rail.
  static const double _compactBelow = 160;

  final List<AppSidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String title;
  final String subtitle;
  final bool collapsed;
  final VoidCallback onToggleCollapsed;
  final String toggleLabel;

  /// Shown at the bottom (signed-in user, sign out). Receives whether the rail is compact.
  final Widget Function(BuildContext context, bool compact)? footer;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.of(context, AppDurations.expand),
      curve: AppDurations.standard,
      width: collapsed ? collapsedWidth : expandedWidth,
      decoration: BoxDecoration(
        color: AppColors.sidebar.resolveFrom(context),
        border: BorderDirectional(
          end: BorderSide(color: AppColors.separator.resolveFrom(context), width: 0.5),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < _compactBelow;
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  compact: compact,
                  title: title,
                  subtitle: subtitle,
                  toggleLabel: toggleLabel,
                  onToggle: onToggleCollapsed,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final previous = index > 0 ? items[index - 1].section : null;
                      final startsSection = item.section != null && item.section != previous;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (startsSection)
                            _SectionTitle(text: item.section!, compact: compact, first: index == 0),
                          _SidebarTile(
                            item: item,
                            selected: index == selectedIndex,
                            compact: compact,
                            onTap: () => onSelected(index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (footer != null) footer!(context, compact),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.compact,
    required this.title,
    required this.subtitle,
    required this.toggleLabel,
    required this.onToggle,
  });

  final bool compact;
  final String title;
  final String subtitle;
  final String toggleLabel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final toggle = Tooltip(
      message: toggleLabel,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(32),
        onPressed: onToggle,
        child: Icon(
          AppIcons.sidebar,
          size: 18,
          color: AppColors.textSecondary.resolveFrom(context),
          semanticLabel: toggleLabel,
        ),
      ),
    );

    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            const AppLogo(size: 36),
            const SizedBox(height: AppSpacing.xs),
            toggle,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        children: [
          const AppLogo(size: 36),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headline.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary.resolveFrom(context)),
                ),
              ],
            ),
          ),
          toggle,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.compact, required this.first});

  final String text;
  final bool compact;
  final bool first;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: first ? 0 : AppSpacing.xs),
        child: first
            ? const SizedBox.shrink()
            : Container(height: 0.5, color: AppColors.separator.resolveFrom(context)),
      );
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.sm,
        end: AppSpacing.sm,
        top: first ? AppSpacing.xxs : AppSpacing.md,
        bottom: AppSpacing.xxs,
      ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textTertiary.resolveFrom(context),
        ),
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final AppSidebarItem item;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> with SingleTickerProviderStateMixin {
  var _hovered = false;

  late final AnimationController _ring = AnimationController(vsync: this, duration: _ringDuration);

  static const _ringDuration = Duration(milliseconds: 700);

  /// A bell's swing: left, right, smaller each time, back to rest (in turns).
  late final Animation<double> _swing = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -0.06), weight: 10),
    TweenSequenceItem(tween: Tween(begin: -0.06, end: 0.06), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 0.06, end: -0.04), weight: 20),
    TweenSequenceItem(tween: Tween(begin: -0.04, end: 0.03), weight: 20),
    TweenSequenceItem(tween: Tween(begin: 0.03, end: 0), weight: 30),
  ]).animate(_ring);

  @override
  void didUpdateWidget(_SidebarTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rings = widget.item.badge > oldWidget.item.badge;
    if (rings && AppDurations.of(context, _ringDuration) != Duration.zero) _ring.forward(from: 0);
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final selected = widget.selected;
    final accent = AppColors.accent.resolveFrom(context);
    final tileColor = item.color == null ? null : CupertinoDynamicColor.resolve(item.color!, context);
    // Selected: white on the accent, like a focused macOS sidebar.
    final color = selected ? AppColors.onBrand : AppColors.textPrimary.resolveFrom(context);
    final background = selected
        ? accent
        : _hovered
        ? AppColors.hover.resolveFrom(context)
        : const Color(0x00000000);
    final glyph = RotationTransition(
      turns: _swing,
      alignment: Alignment.topCenter,
      child: tileColor == null
          ? Icon(selected ? (item.activeIcon ?? item.icon) : item.icon, size: 19, color: color)
          : _IconTile(icon: item.icon, color: tileColor, raised: selected),
    );
    final icon = widget.compact
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              glyph,
              PositionedDirectional(top: -6, end: -10, child: _CountPill(count: item.badge)),
            ],
          )
        : glyph;

    final tile = Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppDurations.of(context, AppDurations.micro),
            height: 36,
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(color: background, borderRadius: AppRadii.smRadius),
            child: widget.compact
                ? Center(child: icon)
                : Row(
                    children: [
                      icon,
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subheadline.copyWith(
                            color: color,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                      _CountPill(count: item.badge),
                    ],
                  ),
          ),
        ),
      ),
    );

    return widget.compact ? Tooltip(message: item.label, child: tile) : tile;
  }
}

/// A white glyph on a rounded square of [color], lit from above: the System Settings icon.
class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color, required this.raised});

  final IconData icon;
  final Color color;

  /// On the blue selection: a thin white ring keeps a blue tile from melting into it.
  final bool raised;

  @override
  Widget build(BuildContext context) {
    final top = Color.lerp(color, const Color(0xFFFFFFFF), 0.18)!;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6.5)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, color],
        ),
        border: raised ? Border.all(color: const Color(0xCCFFFFFF)) : null,
      ),
      child: Icon(icon, size: 14, color: AppColors.onBrand),
    );
  }
}

/// The red count on an item: pops in with a spring when it changes, gone at zero, "99+" past 99.
class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.of(context, AppDurations.bounce),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: count <= 0
          ? const SizedBox.shrink()
          : Container(
              key: ValueKey(count),
              constraints: const BoxConstraints(minWidth: 18),
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.destructive.resolveFrom(context),
                borderRadius: const BorderRadius.all(Radius.circular(9)),
                border: Border.all(color: AppColors.sidebar.resolveFrom(context), width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                semanticsLabel: '$count',
                style: AppTypography.tabular(
                  AppTypography.caption.copyWith(
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBrand,
                  ),
                ),
              ),
            ),
    );
  }
}
