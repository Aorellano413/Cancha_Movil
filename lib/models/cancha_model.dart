// models/cancha_model.dart

enum TipoCancha {
  abierta,
  cerrada,
}

class CanchaModel {
  final String image;
  final String title;
  final String price;
  final String horario;
  final TipoCancha tipo;

  CanchaModel({
    required this.image,
    required this.title,
    required this.price,
    required this.horario,
    required this.tipo,
  });

  factory CanchaModel.fromJson(Map<String, dynamic> json) {
    return CanchaModel(
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      horario: json['horario'] ?? '',
      tipo: json['tipo'] == 'cerrada' ? TipoCancha.cerrada : TipoCancha.abierta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'price': price,
      'horario': horario,
      'tipo': tipo == TipoCancha.cerrada ? 'cerrada' : 'abierta',
    };
  }
}