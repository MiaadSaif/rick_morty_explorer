/// Pagination info returned by the API alongside character results.
class InfoDto {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  const InfoDto({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  factory InfoDto.fromJson(Map<String, dynamic> json) {
    return InfoDto(
      count: (json['count'] as num?)?.toInt() ?? 0,
      pages: (json['pages'] as num?)?.toInt() ?? 0,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'pages': pages,
        'next': next,
        'prev': prev,
      };
}
