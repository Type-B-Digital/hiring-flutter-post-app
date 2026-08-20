class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int skip;
  final int limit;

  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
    String itemsKey,
  ) {
    return PaginatedResponse<T>(
      items: (json[itemsKey] as List).map((i) => fromJsonT(i)).toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}
