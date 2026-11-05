import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medstore_core/medstore_core.dart';

import '../../../app/di/injection.dart';
import '../domain/school.dart';
import '../domain/school_repository.dart';
import 'schools_page.dart';

/// `/schools`.
GoRoute schoolsRoute() => GoRoute(
  path: '/schools',
  pageBuilder: (_, _) => NoTransitionPage(
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: sl<ListSchools>()),
        RepositoryProvider.value(value: sl<SaveSchool>()),
      ],
      child: BlocProvider(
        create: (_) => LoadCubit<List<School>>(() => sl<ListSchools>()(const SchoolFilter()))..load(),
        child: const SchoolsPage(),
      ),
    ),
  ),
);
