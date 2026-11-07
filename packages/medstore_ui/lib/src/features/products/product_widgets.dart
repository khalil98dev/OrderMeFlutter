import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../components/display/app_badge.dart';
import '../../formatting/money_format.dart';
import '../../l10n/app_strings.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icons.dart';
import '../../tokens/app_tone.dart';
import '../../tokens/app_typography.dart';

/// The name of a product type in the user's language.
String productTypeText(AppStrings strings, ProductType type) => switch (type) {
  ProductType.guide => strings.productTypeGuide,
  ProductType.practiceBook => strings.productTypePracticeBook,
  ProductType.examCollection => strings.productTypeExamCollection,
  ProductType.other => strings.productTypeOther,
};

/// "Available" in teal or "Unavailable" in orange.
class ProductAvailabilityBadge extends StatelessWidget {
  const ProductAvailabilityBadge({super.key, required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return isAvailable
        ? AppBadge(label: strings.productAvailable, tone: AppTone.success)
        : AppBadge(label: strings.productUnavailable, tone: AppTone.warning, icon: AppIcons.paused);
  }
}

/// A product's price per copy, or "Price hidden" when this user may not see prices.
///
/// The price is a secured field on the server: a role without the right gets `null`, which must never be
/// shown as 0 DA.
class ProductPrice extends StatelessWidget {
  const ProductPrice({super.key, required this.price, this.style, this.perCopy = false});

  final num? price;

  /// Defaults to [AppTypography.body].
  final TextStyle? style;

  /// Adds "/ copy" after the amount.
  final bool perCopy;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final price = this.price;
    if (price == null) {
      return Text(
        strings.priceHidden,
        style: (style ?? AppTypography.body).copyWith(color: AppColors.textTertiary.resolveFrom(context)),
      );
    }
    final amount = MoneyFormat.dzd(price, Localizations.localeOf(context));
    return Text(
      perCopy ? strings.pricePerCopy(amount) : amount,
      style: AppTypography.tabular(
        style ?? AppTypography.body,
      ).copyWith(color: AppColors.textPrimary.resolveFrom(context)),
    );
  }
}
