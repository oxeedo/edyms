class BannerModel {
  final int id;
  final String? title;
  final String? subtitle;
  final String? imagePath;
  final String? link;
  final String? buttonText;
  final int order;
  final bool isActive;

  BannerModel({
    required this.id,
    this.title,
    this.subtitle,
    this.imagePath,
    this.link,
    this.buttonText,
    required this.order,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'],
      subtitle: json['subtitle'],
      imagePath: json['image_path'],
      link: json['link'],
      buttonText: json['button_text'],
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
}
