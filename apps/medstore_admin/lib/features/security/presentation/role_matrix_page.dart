import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../domain/security.dart';
import 'role_matrix_cubit.dart';

/// One role's permissions: every securable resource with its actions, and its secured fields below it.
/// Ticked boxes are granted; greyed ones cannot be granted on that resource.
///
/// Expects a [RoleMatrixCubit] (loaded) above it.
class RoleMatrixPage extends StatelessWidget {
  const RoleMatrixPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<RoleMatrixCubit>();

    return BlocConsumer<RoleMatrixCubit, RoleMatrixState>(
      listenWhen: (previous, current) => current.justSaved && !previous.justSaved,
      listener: (context, state) => showAppToast(context, strings.permissionsSaved, tone: AppTone.success),
      builder: (context, state) {
        final matrix = state.matrix;
        return AdminPage(
          title: strings.permissionsOf(cubit.role),
          subtitle: matrix?.description,
          onBack: () => context.pop(),
          actions: [
            AppButton(
              label: strings.cancel,
              variant: AppButtonVariant.plain,
              onPressed: state.isDirty && !state.isSaving ? cubit.revert : null,
            ),
            AppButton(
              label: strings.save,
              icon: CupertinoIcons.check_mark,
              isLoading: state.isSaving,
              onPressed: state.isDirty ? cubit.save : null,
            ),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cubit.role == Role.adminName) ...[
                AppMessage(text: strings.adminRoleNotice, tone: AppTone.info),
                const SizedBox(height: AppSpacing.md),
              ],
              if (state.failure case final failure? when matrix != null) ...[
                AppMessage(text: problemText(strings, failure)),
                const SizedBox(height: AppSpacing.md),
              ],
              Expanded(
                child: AppLoadView(
                  isLoading: state.isLoading || (matrix == null && state.failure == null),
                  hasData: matrix != null,
                  failure: state.failure,
                  onRetry: cubit.load,
                  empty: const SizedBox.shrink(),
                  builder: (context) => _Grid(matrix: matrix!),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.matrix});

  final RoleMatrix matrix;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<RoleMatrixCubit>();
    final header = AppTypography.footnote.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary.resolveFrom(context),
    );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(child: Text(strings.resourceCol, style: header)),
                for (final action in ResourceAction.values)
                  SizedBox(
                    width: 90,
                    child: Text(
                      resourceActionText(strings, action),
                      style: header,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: matrix.resources.length,
              itemBuilder: (context, index) {
                final resource = matrix.resources[index];
                return DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.separator.resolveFrom(context), width: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(resource.name, style: AppTypography.headline)),
                            for (final action in ResourceAction.values)
                              SizedBox(
                                width: 90,
                                child: Center(
                                  child: AppCheckbox(
                                    label: '${resource.name} · ${resourceActionText(strings, action)}',
                                    showLabel: false,
                                    value: resource.granted.contains(action),
                                    onChanged: resource.available.contains(action)
                                        ? (_) => cubit.toggle(resource.name, action)
                                        : null,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        for (final field in resource.fields)
                          Row(
                            children: [
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Text(
                                  '${strings.securedFields}: ${field.name}',
                                  style: AppTypography.subheadline.copyWith(
                                    color: AppColors.textSecondary.resolveFrom(context),
                                  ),
                                ),
                              ),
                              // A field's Read and Set sit under the resource's Read and Set columns.
                              for (final column in ResourceAction.values)
                                SizedBox(
                                  width: 90,
                                  child: switch (_fieldAction(column)) {
                                    null => const SizedBox.shrink(),
                                    final action => Center(
                                      child: AppCheckbox(
                                        label:
                                            '${resource.name}.${field.name} · ${fieldActionText(strings, action)}',
                                        showLabel: false,
                                        value: field.granted.contains(action),
                                        onChanged: field.available.contains(action)
                                            ? (_) => cubit.toggleField(resource.name, field.name, action)
                                            : null,
                                      ),
                                    ),
                                  },
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static FieldAction? _fieldAction(ResourceAction column) => switch (column) {
    ResourceAction.read => FieldAction.read,
    ResourceAction.set => FieldAction.set,
    ResourceAction.create || ResourceAction.delete => null,
  };
}
