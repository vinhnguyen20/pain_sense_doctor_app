class PaginatedResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final int limit;

  const PaginatedResponse({
    required this.items,
    this.nextCursor,
    required this.limit,
  });

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    final rawCursor = json['next_cursor'];

    return PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>)
          .map((item) => fromJsonT(item))
          .toList(),
      nextCursor: (rawCursor is String && rawCursor.isNotEmpty)
          ? rawCursor
          : null,
      limit: (json['limit'] as num).toInt(),
    );
  }
}
