import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';
import 'package:medstore_ui/medstore_ui.dart';

import '../../../app/l10n/labels.dart';
import '../../../app/shell/admin_page.dart';
import '../../../app/widgets/submit_dialog.dart';
import '../domain/school.dart';
import '../domain/school_repository.dart';
import 'school_form_dialog.dart';

/// Schools: search, filter by wilaya, create, edit.
///
/// Expects a `LoadCubit<List<School>>` (the list for the current filter) and [ListSchools] /
/// [SaveSchool] above it; the route provides them.
class SchoolsPage extends StatefulWidget {
  const SchoolsPage({super.key});

  @override
  State<SchoolsPage> createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  var _filter = const SchoolFilter();

  void _apply(SchoolFilter filter) {
    _filter = filter;
    final list = context.read<ListSchools>();
    context.read<LoadCubit<List<School>>>().loadWith(() => list(filter));
  }

  Future<void> _edit([School? school]) async {
    final strings = AppStrings.of(context);
    final save = context.read<SaveSchool>();
    final result = await showSubmitDialog<void>(
      context,
      builder: (_) => SchoolFormDialog(save: save, school: school),
    );
    if (!result.saved || !mounted) return;
    showAppToast(context, strings.schoolSaved, tone: AppTone.success);
    _apply(_filter);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final count = context.select<LoadCubit<List<School>>, int>((cubit) => cubit.state.data?.length ?? 0);
    return AdminPage(
      title: strings.navSchools,
      subtitle: count > 0 ? strings.schoolsCount(count) : null,
      actions: [AppButton(label: strings.newSchool, icon: CupertinoIcons.add, onPressed: _edit)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchField(
                  placeholder: strings.searchSchools,
                  onChanged: (text) => _apply(SchoolFilter(search: text, wilayaCode: _filter.wilayaCode)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 160,
                child: AppSearchField(
                  placeholder: strings.fieldWilaya,
                  onChanged: (text) =>
                      _apply(SchoolFilter(search: _filter.search, wilayaCode: int.tryParse(text.trim()))),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _SchoolTable(onEdit: _edit)),
        ],
      ),
    );
  }
}

class _SchoolTable extends StatelessWidget {
  const _SchoolTable({required this.onEdit});

  final ValueChanged<School> onEdit;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final cubit = context.read<LoadCubit<List<School>>>();
    final state = context.watch<LoadCubit<List<School>>>().state;
    final schools = state.data ?? const <School>[];
    return AppLoadView(
      isLoading: state.isLoading || (!state.hasData && state.failure == null),
      hasData: schools.isNotEmpty,
      failure: state.failure,
      onRetry: cubit.load,
      empty: AppEmptyState(
        icon: CupertinoIcons.building_2_fill,
        title: strings.noSchoolsTitle,
        message: strings.noSchoolsMessage,
      ),
      builder: (context) => AppTable(
        columns: [
          AppTableColumn(strings.fieldName, flex: 3),
          AppTableColumn(strings.fieldWilaya, width: 110),
          AppTableColumn(strings.fieldCity, flex: 2),
          AppTableColumn(strings.fieldSchoolLevel, width: 130),
          AppTableColumn(strings.fieldSchoolType, width: 100),
        ],
        rowCount: schools.length,
        onRowTap: (index) => onEdit(schools[index]),
        cells: (context, index) {
          final school = schools[index];
          return [
            Text(school.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${school.wilayaCode}'),
            Text(school.city ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis),
            AppBadge(label: schoolLevelText(strings, school.level)),
            Text(schoolTypeText(strings, school.type)),
          ];
        },
      ),
    );
  }
}
