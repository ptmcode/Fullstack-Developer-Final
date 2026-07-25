/// Generic wrapper for the backend's page envelope:
/// `{content: [...], page, size, totalElements, totalPages}`.
class PagedData<T> {
  PagedData({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  bool get isFirst => page <= 0;
  bool get isLast => page >= totalPages - 1;

  factory PagedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    return PagedData<T>(
      content: ((json['content'] as List?) ?? const [])
          .cast<Map>()
          .map((e) => itemFromJson(e.cast<String, dynamic>()))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }

  static PagedData<T> empty<T>() =>
      PagedData<T>(content: [], page: 0, size: 0, totalElements: 0, totalPages: 0);
}
