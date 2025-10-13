// models/cancha_model.dart

enum TipoCancha {
  abierta,
  cerrada,
  natural,
  techada,
  sintetica,
}

class CanchaModel {
  final String image;
  final String title;
  final String price;
  final String horario;
  final TipoCancha tipo;
  final String jugadores; 

  CanchaModel({
    required this.image,
    required this.title,
    required this.price,
    required this.horario,
    required this.tipo,
    required this.jugadores, 
  });

  factory CanchaModel.fromJson(Map<String, dynamic> json) {
    return CanchaModel(
      image: json['image'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      horario: json['horario'] ?? '',
      tipo: _parseTipoCancha(json['tipo']),
      jugadores: json['jugadores'] ?? '5 vs 5', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'title': title,
      'price': price,
      'horario': horario,
      'tipo': tipo.name,
      'jugadores': jugadores,
    };
  }

  static TipoCancha _parseTipoCancha(String? tipoStr) {
    switch (tipoStr) {
      case 'cerrada':
        return TipoCancha.cerrada;
      case 'natural':
        return TipoCancha.natural;
      case 'techada':
        return TipoCancha.techada;
      case 'sintetica':
        return TipoCancha.sintetica;
      default:
        return TipoCancha.abierta;
    }
  }
}
