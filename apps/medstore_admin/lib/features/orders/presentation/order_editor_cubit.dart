import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medstore_core/medstore_core.dart';

import '../domain/admin_orders.dart';

final class OrderEditorState extends Equatable {
  const OrderEditorState({
    required this.draft,
    this.teacherName,
    this.products = const [],
    this.isLoadingProducts = false,
    this.problems = const {},
    this.isSaving = false,
    this.failure,
    this.saved,
  });

  final OrderDraft draft;
  final String? teacherName;

  /// The chosen teacher's products that can be ordered.
  final List<Product> products;
  final bool isLoadingProducts;
  final Set<OrderDraftProblem> problems;
  final bool isSaving;
  final Failure? failure;

  /// The order number once placed (a revision keeps its number), or 0 after a revision.
  final int? saved;

  OrderEditorState copyWith({
    OrderDraft? draft,
    String? teacherName,
    List<Product>? products,
    bool? isLoadingProducts,
    Set<OrderDraftProblem>? problems,
    bool? isSaving,
    Failure? failure,
    int? saved,
  }) => OrderEditorState(
    draft: draft ?? this.draft,
    teacherName: teacherName ?? this.teacherName,
    products: products ?? this.products,
    isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
    problems: problems ?? this.problems,
    isSaving: isSaving ?? this.isSaving,
    failure: failure,
    saved: saved,
  );

  @override
  List<Object?> get props => [
    draft,
    teacherName,
    products,
    isLoadingProducts,
    problems,
    isSaving,
    failure,
    saved,
  ];
}

/// A new order taken for a teacher, or the revision of an existing one's lines.
///
/// Choosing the teacher loads their available products; lines are edited locally and sent as a whole.
class OrderEditorCubit extends Cubit<OrderEditorState> {
  OrderEditorCubit({
    required PlaceOrder placeOrder,
    required ReviseOrder reviseOrder,
    required WatchProducts watchProducts,
    Order? existing,
  }) : _placeOrder = placeOrder,
       _reviseOrder = reviseOrder,
       _watchProducts = watchProducts,
       _orderId = existing?.id,
       super(
         OrderEditorState(
           draft: existing == null ? const OrderDraft() : OrderDraft.of(existing),
           teacherName: existing?.clientName,
         ),
       );

  final PlaceOrder _placeOrder;
  final ReviseOrder _reviseOrder;
  final WatchProducts _watchProducts;
  final String? _orderId;

  bool get isRevision => _orderId != null;

  /// Loads the products of the order's teacher (a revision starts with its teacher chosen).
  Future<void> start() async {
    final clientId = state.draft.clientId;
    if (clientId != null) await _loadProducts(clientId);
  }

  /// A new order only: the teacher cannot change on an existing order.
  Future<void> chooseTeacher(String clientId, String name) async {
    if (isRevision) return;
    emit(state.copyWith(draft: state.draft.withClient(clientId), teacherName: name, products: const []));
    await _loadProducts(clientId);
  }

  void add(Product product) => emit(state.copyWith(draft: state.draft.add(product), problems: const {}));

  void setQuantity(String productId, int quantity) =>
      emit(state.copyWith(draft: state.draft.setQuantity(productId, quantity)));

  void remove(String productId) => emit(state.copyWith(draft: state.draft.remove(productId)));

  void setNotes(String notes) => emit(state.copyWith(draft: state.draft.withNotes(notes)));

  Future<void> save() async {
    if (state.isSaving) return;
    final problems = state.draft.validate();
    if (problems.isNotEmpty) {
      emit(state.copyWith(problems: problems));
      return;
    }
    emit(state.copyWith(isSaving: true, problems: const {}));

    final orderId = _orderId;
    final Result<int> result = orderId == null
        ? (await _placeOrder(state.draft)).map((order) => order.number)
        : (await _reviseOrder(ReviseOrderParams(orderId, state.draft))).map((_) => 0);

    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(isSaving: false, saved: value),
      Err(:final failure) => state.copyWith(isSaving: false, failure: failure),
    });
  }

  Future<void> _loadProducts(String clientId) async {
    emit(state.copyWith(isLoadingProducts: true));
    final query = ProductQuery(clientId: clientId, isAvailable: true, pageSize: 100);
    final result = await _watchProducts(WatchProductsParams(query)).last;
    if (isClosed || state.draft.clientId != clientId) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(products: value.items, isLoadingProducts: false),
      Err(:final failure) => state.copyWith(isLoadingProducts: false, failure: failure),
    });
  }
}
