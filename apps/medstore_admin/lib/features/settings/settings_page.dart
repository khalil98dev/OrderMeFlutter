import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../app/forms/form_values.dart';
import '../../app/l10n/labels.dart';
import '../../app/shell/admin_page.dart';
import '../../app/widgets/submit_dialog.dart';
import 'domain/billing_settings.dart';
import 'presentation/change_password_dialog.dart';

/// Settings: the signed-in account (password), billing (AutoSettle, default terms) and the language.
///
/// Expects a `LoadCubit<BillingSettings>`, [SaveBillingSettings] and [ChangePassword] above it.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AdminPage(
      title: strings.navSettings,
      child: SingleChildScrollView(
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AccountSection(),
                const SizedBox(height: AppSpacing.lg),
                const _BillingSection(),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.globe, color: AppColors.brand.resolveFrom(context)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(strings.language, style: AppTypography.body)),
                      LanguageSwitch(
                        current: Localizations.localeOf(context),
                        onChanged: (locale) => context.read<LocaleCubit>().choose(locale),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final user = context.select<AuthCubit, SessionUser?>(
      (cubit) => switch (cubit.state) {
        Authenticated(:final user) => user,
        _ => null,
      },
    );
    return AppSection(
      header: strings.account,
      footer: strings.changePasswordHint,
      dividerIndent: AppSpacing.md,
      children: [
        AppListTile(
          leading: AppAvatar(name: user?.userName ?? '', size: 32),
          title: user?.userName ?? '',
          subtitle: [?user?.email, ...?user?.roleNames].join(' · '),
        ),
        AppListTile(
          title: strings.changePassword,
          onTap: () async {
            final change = context.read<ChangePassword>();
            final result = await showSubmitDialog<void>(
              context,
              builder: (_) => ChangePasswordDialog(changePassword: change),
            );
            if (result.saved && context.mounted) {
              showAppToast(context, strings.passwordChanged, tone: AppTone.success);
            }
          },
        ),
        AppListTile(
          title: strings.signOut,
          destructive: true,
          onTap: () => context.read<AuthCubit>().signOut(),
        ),
      ],
    );
  }
}

class _BillingSection extends StatelessWidget {
  const _BillingSection();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<BillingSettings>>();
    final state = context.watch<LoadCubit<BillingSettings>>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldLabel(strings.billingSettings),
        AppLoadView(
          isLoading: state.isLoading || (!state.hasData && state.failure == null),
          hasData: state.hasData,
          failure: state.failure,
          onRetry: cubit.load,
          empty: const SizedBox.shrink(),
          loading: const AppCard(child: Center(child: CupertinoActivityIndicator())),
          // Keyed on the saved value, so a reload resets the form to what the server holds.
          builder: (context) => _BillingForm(key: ValueKey(state.data), settings: state.data!),
        ),
      ],
    );
  }
}

class _BillingForm extends StatefulWidget {
  const _BillingForm({super.key, required this.settings});

  final BillingSettings settings;

  @override
  State<_BillingForm> createState() => _BillingFormState();
}

class _BillingFormState extends State<_BillingForm> {
  late bool _autoSettle = widget.settings.autoSettle;
  late PaymentTerms _terms = widget.settings.defaultPaymentTerms;
  var _saving = false;

  bool get _changed =>
      _autoSettle != widget.settings.autoSettle || _terms != widget.settings.defaultPaymentTerms;

  Future<void> _save() async {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<BillingSettings>>();
    final save = context.read<SaveBillingSettings>();
    setState(() => _saving = true);
    final result = await save(BillingSettings(autoSettle: _autoSettle, defaultPaymentTerms: _terms));
    if (!mounted) return;
    setState(() => _saving = false);
    switch (result) {
      case Ok(:final value):
        cubit.show(value);
        showAppToast(context, strings.settingsSaved, tone: AppTone.success);
      case Err(:final failure):
        showAppToast(context, problemText(strings, failure), tone: AppTone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final locale = Localizations.localeOf(context);
    final updatedAt = widget.settings.updatedAt;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSwitchRow(
            label: strings.autoSettle,
            description: strings.autoSettleHint,
            value: _autoSettle,
            onChanged: (value) => setState(() => _autoSettle = value),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSelectField<PaymentTerms>(
            label: strings.defaultPaymentTerms,
            options: paymentTermsOptions(strings),
            value: _terms,
            onChanged: (value) => setState(() => _terms = value ?? _terms),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: updatedAt == null
                    ? const SizedBox.shrink()
                    : Text(
                        strings.lastChanged(
                          AppDateFormat.dateTime(updatedAt, locale),
                          widget.settings.updatedByName ?? '—',
                        ),
                        style: AppTypography.footnote.copyWith(
                          color: AppColors.textSecondary.resolveFrom(context),
                        ),
                      ),
              ),
              AppButton(label: strings.save, isLoading: _saving, onPressed: _changed ? _save : null),
            ],
          ),
        ],
      ),
    );
  }
}
