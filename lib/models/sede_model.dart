// lib/models/sede_model.dart
class SedeModel {
  final String? id; 
  final String imagePath;
  final String title;
  final String subtitle; // Esta es la dirección
  final String price;
  final String tag;
  final String? description;
  final bool isCustom;
  final double? latitud;  // ⭐ NUEVO
  final double? longitud; // ⭐ NUEVO

  SedeModel({
    this.id,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.tag,
    this.description,
    this.isCustom = false,
    this.latitud,  // ⭐ NUEVO
    this.longitud, // ⭐ NUEVO
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
      latitud: json['latitud']?.toDouble(),  // ⭐ NUEVO
      longitud: json['longitud']?.toDouble(), // ⭐ NUEVO
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
        if (latitud != null) 'latitud': latitud,   // ⭐ NUEVO
        if (longitud != null) 'longitud': longitud, // ⭐ NUEVO
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
    double? latitud,  // ⭐ NUEVO
    double? longitud, // ⭐ NUEVO
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
      latitud: latitud ?? this.latitud,   // ⭐ NUEVO
      longitud: longitud ?? this.longitud, // ⭐ NUEVO
    );
  }

  // ⭐ NUEVO MÉTODO
  bool tieneCoordenadasValidas() {
    return latitud != null && longitud != null;
  }
}