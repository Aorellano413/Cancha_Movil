// lib/models/sede_model.dart
class SedeModel {
  final String? id;
  final String imagePath;
  final String title;
  final String subtitle;
  final String price;
  final String tag;
  final String? description;
  final bool isCustom;
  
  // Campos para geolocalización
  final double? latitude;
  final double? longitude;
  final double? distanceInKm;

  SedeModel({
    this.id,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.tag,
    this.description,
    this.isCustom = false,
    this.latitude,
    this.longitude,
    this.distanceInKm,
  });

  factory SedeModel.fromJson(Map<String, dynamic> json) {
    return SedeModel(
      id: json['id'],
      imagePath: (json['image'] ?? json['imagePath'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      subtitle: (json['subtitle'] ?? '') as String,
      price: (json['price'] ?? '') as String,
      tag: (json['tag'] ?? '') as String,
      description: json['description'] == null ? null : json['description'] as String,
      isCustom: (json['isCustom'] ?? false) as bool,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'imagePath': imagePath,
        'title': title,
        'subtitle': subtitle,
        'price': price,
        'tag': tag,
        if (description != null) 'description': description,
        'isCustom': isCustom,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

  SedeModel copyWith({
    String? id,
    String? imagePath,
    String? title,
    String? subtitle,
    String? price,
    String? tag,
    String? description,
    bool? isCustom,
    double? latitude,
    double? longitude,
    double? distanceInKm,
  }) {
    return SedeModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
      tag: tag ?? this.tag,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceInKm: distanceInKm ?? this.distanceInKm,
    );
  }

  bool hasValidCoordinates() {
    return latitude != null && longitude != null;
  }
}