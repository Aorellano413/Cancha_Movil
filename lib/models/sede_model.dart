// models/sede_model.dart

class SedeModel {
  final String imagePath;
  final String title;
  final String subtitle;
  final String price;
  final String tag;

  SedeModel({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.tag,
  });

  factory SedeModel.fromJson(Map<String, dynamic> json) {
    return SedeModel(
      imagePath: json['image'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      price: json['price'] ?? '',
      tag: json['tag'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': imagePath,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'tag': tag,
    };
  }
}