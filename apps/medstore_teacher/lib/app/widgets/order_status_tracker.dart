import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../l10n/labels.dart';

/// Where an order is on its way: pending → in preparation → ready → delivered, as four dots on a line.
/// Done steps are filled, the current one glows. A cancelled order shows a single red step instead.
class OrderStatusTracker extends StatelessWidget {
  const OrderStatusTracker({super.key, required this.status});

  final OrderStatus status;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.inPreparation,
    OrderStatus.ready,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    if (status == OrderStatus.cancelled) {
      return AppMessage(
        text: orderStatusText(strings, status),
        tone: AppTone.neutral,
        icon: orderStatusIcon(status),
      );
    }

    final reached = _steps.indexOf(status);
    final brand = AppColors.brand.resolveFrom(context);
    final done = AppColors.signal.resolveFrom(context);
    final idle = AppColors.separator.resolveFrom(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _Line(color: i == 0 ? null : (i <= reached ? done : idle))),
                    _Dot(
                      icon: orderStatusIcon(_steps[i]),
                      color: i < reached || status == OrderStatus.delivered
                          ? done
                          : (i == reached ? brand : idle),
                      current: i == reached && status != OrderStatus.delivered,
                    ),
                    Expanded(
                      child: _Line(color: i == _steps.length - 1 ? null : (i < reached ? done : idle)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  orderStatusText(strings, _steps[i]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTypography.caption.copyWith(
                    fontWeight: i == reached ? FontWeight.w700 : FontWeight.w500,
                    color: i <= reached
                        ? AppColors.textPrimary.resolveFrom(context)
                        : AppColors.textSecondary.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.icon, required this.color, required this.current});

  final IconData icon;
  final Color color;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.of(context, AppDurations.expand),
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: current
            ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12, spreadRadius: 2)]
            : null,
      ),
      child: Icon(icon, size: 17, color: AppColors.onBrand),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.color});

  /// Null: no line (the outer side of the first and last dots).
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    height: 3,
    decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(Radius.circular(2))),
  );
}
