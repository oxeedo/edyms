class CustomPage {
  final int id;
  final String title;
  final String slug;
  final String? content;
  final String? description;

  CustomPage({
    required this.id,
    required this.title,
    required this.slug,
    this.content,
    this.description,
  });

  factory CustomPage.fromJson(Map<String, dynamic> json) {
    return CustomPage(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      content: json['content'],
      description: json['description'],
    );
  }
}
