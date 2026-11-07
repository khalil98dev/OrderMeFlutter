import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../../schools/domain/school.dart';
import '../../schools/domain/school_repository.dart';
import '../domain/statement.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';
import 'teacher_detail_page.dart';
import 'teachers_page.dart';

/// The schools, for the school filter and the teacher form.
BlocProvider<LoadCubit<List<School>>> _schools() => BlocProvider(
  create: (_) => LoadCubit<List<School>>(() => sl<ListSchools>()(const SchoolFilter()))..load(),
);

/// `/teachers` (the list) and `/teachers/:id` (profile and statement).
GoRoute teachersRoute() => GoRoute(
  path: '/teachers',
  pageBuilder: (_, _) => NoTransitionPage(
    child: RepositoryProvider.value(
      value: sl<SaveTeacher>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => TeachersCubit(
              (filter, page) => sl<ListTeachers>()(filter, page: page),
              filter: const TeacherFilter(),
            )..load(),
          ),
          _schools(),
        ],
        child: const TeachersPage(),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: ':id',
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        final today = DateTime.now();
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: sl<SaveTeacher>()),
            RepositoryProvider.value(value: sl<DeactivateTeacher>()),
            RepositoryProvider.value(value: sl<SetTeacherPassword>()),
            RepositoryProvider.value(value: sl<GetStatement>()),
            RepositoryProvider.value(value: sl<DownloadStatementPdf>()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => LoadCubit<Teacher>(() => sl<GetTeacher>()(id))..load()),
              BlocProvider(
                create: (_) => LoadCubit<Statement>(
                  () => sl<GetStatement>()(
                    StatementParams(
                      id,
                      from: DateTime(today.year),
                      to: DateTime(today.year, today.month, today.day),
                    ),
                  ),
                )..load(),
              ),
              _schools(),
            ],
            child: TeacherDetailPage(teacherId: id),
          ),
        );
      },
    ),
  ],
);
