import 'package:flutter/cupertino.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../widgets/gallery_section.dart';

enum _LoadCase { loading, data, error, empty }

class FeedbackSection extends StatefulWidget {
  const FeedbackSection({super.key});

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  var _case = _LoadCase.loading;

  Future<void> _askToCancel() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: tr(context, 'Annuler la commande ?', 'إلغاء الطلب؟'),
      message: tr(context, "L'enseignant sera prévenu.", 'سيتم إعلام الأستاذ.'),
      confirmLabel: tr(context, 'Annuler la commande', 'إلغاء الطلب'),
      destructive: true,
    );
    if (!mounted) return;
    showAppToast(
      context,
      confirmed
          ? tr(context, 'Commande annulée', 'تم إلغاء الطلب')
          : tr(context, 'Rien changé', 'لم يتغير شيء'),
      tone: confirmed ? AppTone.danger : AppTone.neutral,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return GallerySection(
      title: tr(context, 'Retours', 'الرسائل والحالات'),
      components:
          'AppMessage · AppLoadView · AppEmptyState · AppErrorState · AppSkeleton · showAppConfirmDialog · showAppToast',
      children: [
        Demo(
          label: 'AppMessage',
          child: Column(
            children: [
              AppMessage(text: strings.wrongCredentials),
              const SizedBox(height: AppSpacing.xs),
              AppMessage(text: strings.failureNetwork, tone: AppTone.warning),
              const SizedBox(height: AppSpacing.xs),
              AppMessage(text: tr(context, 'Paiement enregistré.', 'تم تسجيل الدفع.'), tone: AppTone.success),
            ],
          ),
        ),
        Demo(
          label: 'AppLoadView — isLoading / hasData / failure',
          width: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSegmentedControl<_LoadCase>(
                segments: const {
                  _LoadCase.loading: 'loading',
                  _LoadCase.data: 'data',
                  _LoadCase.error: 'error',
                  _LoadCase.empty: 'empty',
                },
                selected: _case,
                onChanged: (value) => setState(() => _case = value),
              ),
              SizedBox(
                height: 300,
                child: AppLoadView(
                  isLoading: _case == _LoadCase.loading,
                  hasData: _case == _LoadCase.data,
                  failure: _case == _LoadCase.error ? const NetworkFailure() : null,
                  onRetry: () => setState(() => _case = _LoadCase.loading),
                  empty: AppEmptyState(
                    icon: AppIcons.cart,
                    title: tr(context, 'Aucune commande', 'لا توجد طلبات'),
                    message: tr(
                      context,
                      'Les nouvelles commandes apparaîtront ici.',
                      'ستظهر الطلبات الجديدة هنا.',
                    ),
                  ),
                  builder: (context) => ListView(
                    children: [
                      for (final name in ['Amina Benali', 'Karim Ait Said', 'Yacine Haddad'])
                        AppListTile(
                          leading: AppAvatar(name: name),
                          title: name,
                          onTap: () {},
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Demo(
          label: 'showAppConfirmDialog · showAppToast',
          child: Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: tr(context, 'Annuler la commande', 'إلغاء الطلب'),
                variant: AppButtonVariant.destructive,
                onPressed: _askToCancel,
              ),
              AppButton(
                label: tr(context, 'Toast succès', 'إشعار نجاح'),
                variant: AppButtonVariant.tinted,
                onPressed: () => showAppToast(
                  context,
                  tr(context, 'Commande enregistrée', 'تم حفظ الطلب'),
                  tone: AppTone.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
