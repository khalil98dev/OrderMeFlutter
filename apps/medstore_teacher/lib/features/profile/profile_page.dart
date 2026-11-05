import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/shell/teacher_page.dart';

/// The teacher's account: who is signed in, the language, and sign out.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final user = context.select<AuthCubit, SessionUser?>(
      (cubit) => switch (cubit.state) {
        Authenticated(:final user) => user,
        _ => null,
      },
    );

    return TeacherPage(
      title: strings.navProfile,
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenMobile,
          sliver: SliverList.list(
            children: [
              AppCard(
                child: Row(
                  children: [
                    const AppLogo(size: 44),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.userName ?? '',
                            style: AppTypography.headline.copyWith(
                              color: AppColors.textPrimary.resolveFrom(context),
                            ),
                          ),
                          if (user?.email case final email?)
                            Text(
                              email,
                              style: AppTypography.footnote.copyWith(
                                color: AppColors.textSecondary.resolveFrom(context),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Row(
                  children: [
                    Icon(CupertinoIcons.globe, color: AppColors.brand.resolveFrom(context)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        strings.language,
                        style: AppTypography.body.copyWith(color: AppColors.textPrimary.resolveFrom(context)),
                      ),
                    ),
                    LanguageSwitch(
                      current: Localizations.localeOf(context),
                      onChanged: (locale) => context.read<LocaleCubit>().choose(locale),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: strings.signOut,
                icon: CupertinoIcons.square_arrow_right,
                variant: AppButtonVariant.destructive,
                expand: true,
                onPressed: () => context.read<AuthCubit>().signOut(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
