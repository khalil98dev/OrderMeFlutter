import 'package:equatable/equatable.dart';

/// One page of a longer list, as the API returns it (`PagedResult<T>`).
final class PagedList<T> extends Equatable {
  const PagedList({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  const PagedList.empty() : items = const [], page = 1, pageSize = 20, totalCount = 0;

  /// Reads `{items, page, pageSize, totalCount}`, building each item with [item].
  factory PagedList.fromJson(Object? json, T Function(Object? json) item) {
    final map = json! as Map<String, Object?>;
    return PagedList(
      items: [for (final element in map['items']! as List<Object?>) item(element)],
      page: map['page']! as int,
      pageSize: map['pageSize']! as int,
      totalCount: map['totalCount']! as int,
    );
  }

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;

  bool get hasMore => page * pageSize < totalCount;

  @override
  List<Object?> get props => [items, page, pageSize, totalCount];
}
