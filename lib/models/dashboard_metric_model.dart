class DashboardMetric {
  final String id;
  final String title;
  final int value;
  final String route;
  final Map<String, dynamic> filters;
  final String? subtitle;

  const DashboardMetric({
    required this.id,
    required this.title,
    required this.value,
    required this.route,
    this.filters = const {},
    this.subtitle,
  });

  factory DashboardMetric.fromJson(Map<String, dynamic> json) {
    return DashboardMetric(
      id: json['id'] as String,
      title: json['title'] as String,
      value: json['value'] as int? ?? 0,
      route: json['route'] as String? ?? '',
      filters: Map<String, dynamic>.from(
        json['filters'] as Map<String, dynamic>? ?? const {},
      ),
      subtitle: json['subtitle'] as String?,
    );
  }
}
