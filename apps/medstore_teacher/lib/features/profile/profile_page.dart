import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/shell/teacher_page.dart';
import '../../app/widgets/soft_card.dart';

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
              SoftCard(
                child: Row(
                  children: [
                    AppAvatar(name: user?.userName ?? '', size: 52),
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
              SoftCard(
                child: Row(
                  children: [
                    Icon(AppIcons.language, color: AppColors.brand.resolveFrom(context)),
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
                icon: AppIcons.signOut,
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
