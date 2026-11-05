import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';

import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';

final class NewInvoiceState extends Equatable {
  const NewInvoiceState({
    this.draft = const InvoiceDraft(clientId: null, available: []),
    this.teacherName,
    this.isLoading = false,
    this.problems = const {},
    this.isIssuing = false,
    this.failure,
    this.issued,
  });

  final InvoiceDraft draft;
  final String? teacherName;

  /// The teacher's uninvoiced copies are loading.
  final bool isLoading;
  final Set<InvoiceDraftProblem> problems;
  final bool isIssuing;
  final Failure? failure;

  /// The invoice once issued.
  final Invoice? issued;

  NewInvoiceState copyWith({
    InvoiceDraft? draft,
    String? teacherName,
    bool? isLoading,
    Set<InvoiceDraftProblem>? problems,
    bool? isIssuing,
    Failure? failure,
    Invoice? issued,
  }) => NewInvoiceState(
    draft: draft ?? this.draft,
    teacherName: teacherName ?? this.teacherName,
    isLoading: isLoading ?? this.isLoading,
    problems: problems ?? this.problems,
    isIssuing: isIssuing ?? this.isIssuing,
    failure: failure,
    issued: issued,
  );

  @override
  List<Object?> get props => [draft, teacherName, isLoading, problems, isIssuing, failure, issued];
}

/// Invoicing a teacher: pick them, see their uninvoiced copies (all selected), adjust quantities, issue.
class NewInvoiceCubit extends Cubit<NewInvoiceState> {
  NewInvoiceCubit({required ListUninvoiced listUninvoiced, required IssueInvoice issueInvoice})
    : _listUninvoiced = listUninvoiced,
      _issueInvoice = issueInvoice,
      super(const NewInvoiceState());

  final ListUninvoiced _listUninvoiced;
  final IssueInvoice _issueInvoice;

  Future<void> chooseTeacher(String clientId, String name) async {
    emit(
      NewInvoiceState(
        draft: InvoiceDraft(clientId: clientId, available: const []),
        teacherName: name,
        isLoading: true,
      ),
    );
    final result = await _listUninvoiced(clientId);
    if (isClosed || state.draft.clientId != clientId) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(
        draft: InvoiceDraft(clientId: clientId, available: value).selectAll(),
        isLoading: false,
      ),
      Err(:final failure) => state.copyWith(isLoading: false, failure: failure),
    });
  }

  void setQuantity(String key, int quantity) =>
      emit(state.copyWith(draft: state.draft.setQuantity(key, quantity), problems: const {}));

  void setNotes(String notes) => emit(state.copyWith(draft: state.draft.withNotes(notes)));

  Future<void> issue() async {
    if (state.isIssuing) return;
    final problems = state.draft.validate();
    if (problems.isNotEmpty) {
      emit(state.copyWith(problems: problems));
      return;
    }
    emit(state.copyWith(isIssuing: true));
    final result = await _issueInvoice(state.draft);
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(isIssuing: false, issued: value),
      Err(:final failure) => state.copyWith(isIssuing: false, failure: failure),
    });
  }
}
