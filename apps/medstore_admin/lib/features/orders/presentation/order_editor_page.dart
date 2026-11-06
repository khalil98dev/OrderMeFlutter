import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/forms/form_values.dart';
import '../../../app/shell/admin_page.dart';
import '../../teachers/domain/teacher_directory.dart';
import '../../teachers/presentation/teacher_filter_field.dart';
import '../domain/admin_orders.dart';
import 'order_editor_cubit.dart';

/// A new order for a teacher (by phone, at the counter), or new lines for an existing one.
/// Comes back with the toast text when saved.
///
/// Expects an [OrderEditorCubit] (started) and [SearchTeachers] above it.
class OrderEditorPage extends StatefulWidget {
  const OrderEditorPage({super.key, this.orderNumber});

  /// The order being revised; null for a new order.
  final int? orderNumber;

  @override
  State<OrderEditorPage> createState() => _OrderEditorPageState();
}

class _OrderEditorPageState extends State<OrderEditorPage> {
  late final _notes = TextEditingController(text: context.read<OrderEditorCubit>().state.draft.notes);

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<OrderEditorCubit>();
    final number = widget.orderNumber;

    return BlocConsumer<OrderEditorCubit, OrderEditorState>(
      listenWhen: (previous, current) => current.saved != null && previous.saved == null,
      listener: (context, state) =>
          context.pop(state.saved! > 0 ? strings.orderPlaced(state.saved!) : strings.orderSaved),
      builder: (context, state) {
        final problems = state.problems;
        return AdminPage(
          title: number == null ? strings.newOrder : strings.orderNumber(number),
          subtitle: number == null ? null : strings.reviseOrder,
          onBack: state.isSaving ? null : () => context.pop(),
          actions: [
            AppButton(
              label: strings.save,
              icon: AppIcons.check,
              isLoading: state.isSaving,
              onPressed: cubit.save,
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.failure case final failure?) ...[
                  AppMessage(text: problemText(strings, failure)),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (number != null) ...[
                  AppMessage(text: strings.orderEditableHint, tone: AppTone.info),
                  const SizedBox(height: AppSpacing.md),
                ],
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 360,
                        child: TeacherFilterField(
                          search: context.read<SearchTeachers>(),
                          teacherName: state.teacherName,
                          allowNone: false,
                          errorText: problems.contains(OrderDraftProblem.teacherRequired)
                              ? strings.fieldRequired
                              : null,
                          onChanged: cubit.isRevision
                              ? (_) {}
                              : (teacher) {
                                  if (teacher != null) cubit.chooseTeacher(teacher.$1, teacher.$2);
                                },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: strings.fieldNotes,
                        controller: _notes,
                        maxLines: 3,
                        onChanged: cubit.setNotes,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const _Lines(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<OrderEditorCubit>();
    final state = context.watch<OrderEditorCubit>().state;
    final lines = state.draft.lines;
    final hasTeacher = state.draft.clientId != null;
    final linesError = state.problems.contains(OrderDraftProblem.linesRequired);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: AppFieldLabel(strings.orderLines, isRequired: true)),
            SizedBox(
              width: 360,
              child: AppSelectField<String>(
                label: strings.addProduct,
                placeholder: hasTeacher
                    ? (state.isLoadingProducts ? strings.loading : strings.chooseProduct)
                    : strings.chooseTeacherFirst,
                icon: AppIcons.add,
                options: {
                  for (final product in state.products)
                    product.id: product.code == null ? product.name : '${product.name} (${product.code})',
                },
                value: null,
                onChanged: hasTeacher && state.products.isNotEmpty
                    ? (id) {
                        final product = state.products.where((p) => p.id == id).firstOrNull;
                        if (product != null) cubit.add(product);
                      }
                    : null,
              ),
            ),
          ],
        ),
        if (hasTeacher && !state.isLoadingProducts && state.products.isEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          AppMessage(text: strings.noProductsForTeacher, tone: AppTone.warning),
        ],
        const SizedBox(height: AppSpacing.sm),
        if (lines.isEmpty)
          AppMessage(text: strings.noLines, tone: linesError ? AppTone.danger : AppTone.neutral)
        else
          AppTable(
            shrinkWrap: true,
            columns: [
              // Product and quantity first: what is ordered and how many.
              AppTableColumn(strings.colProduct, flex: 3),
              AppTableColumn(strings.colQuantity, width: 150),
              AppTableColumn.amount(strings.colUnitPrice),
              AppTableColumn.amount(strings.colTotal),
              const AppTableColumn('', width: 44),
            ],
            rowCount: lines.length,
            cells: (context, index) {
              final line = lines[index];
              final price = line.unitPrice;
              return [
                Text(
                  line.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subheadline.copyWith(fontWeight: FontWeight.w600),
                ),
                AppQuantityStepper(
                  value: line.quantity,
                  min: 1,
                  max: OrderDraft.maxQuantity,
                  onChanged: (quantity) => cubit.setQuantity(line.productId, quantity),
                ),
                price == null ? const Text('—') : AppMoney(price, style: AppTypography.subheadline),
                price == null
                    ? const Text('—')
                    : AppMoney(price * line.quantity, style: AppTypography.subheadline),
                AppIconButton(
                  icon: AppIcons.delete,
                  label: strings.remove,
                  tone: AppTone.danger,
                  onPressed: () => cubit.remove(line.productId),
                ),
              ];
            },
          ),
        if (lines.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              width: 320,
              child: AppInfoRow(
                label: strings.total,
                emphasized: true,
                child: AppMoney(state.draft.total, style: AppTypography.headline),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
