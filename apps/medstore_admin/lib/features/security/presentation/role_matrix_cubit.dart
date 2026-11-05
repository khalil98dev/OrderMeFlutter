import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';

import '../domain/security.dart';

final class RoleMatrixState extends Equatable {
  const RoleMatrixState({
    this.matrix,
    this.saved,
    this.isLoading = false,
    this.isSaving = false,
    this.failure,
    this.justSaved = false,
  });

  /// The grid as edited.
  final RoleMatrix? matrix;

  /// The grid as the server has it.
  final RoleMatrix? saved;
  final bool isLoading;
  final bool isSaving;
  final Failure? failure;

  /// True right after a successful save (for the toast).
  final bool justSaved;

  bool get isDirty => matrix != saved;

  RoleMatrixState copyWith({
    RoleMatrix? matrix,
    RoleMatrix? saved,
    bool? isLoading,
    bool? isSaving,
    Failure? failure,
    bool justSaved = false,
  }) => RoleMatrixState(
    matrix: matrix ?? this.matrix,
    saved: saved ?? this.saved,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    failure: failure,
    justSaved: justSaved,
  );

  @override
  List<Object?> get props => [matrix, saved, isLoading, isSaving, failure, justSaved];
}

/// One role's permission grid: load it, tick and untick, save it all at once (or put it back).
class RoleMatrixCubit extends Cubit<RoleMatrixState> {
  RoleMatrixCubit({required GetRoleMatrix getMatrix, required SaveRoleMatrix saveMatrix, required this.role})
    : _getMatrix = getMatrix,
      _saveMatrix = saveMatrix,
      super(const RoleMatrixState());

  final GetRoleMatrix _getMatrix;
  final SaveRoleMatrix _saveMatrix;
  final String role;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    final result = await _getMatrix(role);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => RoleMatrixState(matrix: value, saved: value),
      Err(:final failure) => state.copyWith(isLoading: false, failure: failure),
    });
  }

  void toggle(String resource, ResourceAction action) {
    final matrix = state.matrix;
    if (matrix != null && !state.isSaving) emit(state.copyWith(matrix: matrix.toggled(resource, action)));
  }

  void toggleField(String resource, String field, FieldAction action) {
    final matrix = state.matrix;
    if (matrix != null && !state.isSaving) {
      emit(state.copyWith(matrix: matrix.fieldToggled(resource, field, action)));
    }
  }

  /// Back to what the server has.
  void revert() => emit(RoleMatrixState(matrix: state.saved, saved: state.saved));

  Future<void> save() async {
    final matrix = state.matrix;
    if (matrix == null || state.isSaving || !state.isDirty) return;
    emit(state.copyWith(isSaving: true));
    final result = await _saveMatrix(matrix);
    if (isClosed) return;
    emit(switch (result) {
      Ok() => RoleMatrixState(matrix: matrix, saved: matrix, justSaved: true),
      Err(:final failure) => state.copyWith(isSaving: false, failure: failure),
    });
  }
}
