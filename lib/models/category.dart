class Category {
  final int id;
  final String name;
  final String? slug;
  final String? icon;

  Category({required this.id, required this.name, this.slug, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] ?? '',
      slug: json['slug'],
      icon: json['icon'],
    );
  }
}
