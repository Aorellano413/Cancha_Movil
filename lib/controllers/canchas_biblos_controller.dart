// controllers/canchas_biblos_controller.dart
import 'package:flutter/material.dart';
import '../models/cancha_model.dart';

class CanchasBiblosController extends ChangeNotifier {
  final List<CanchaModel> _canchas = [
    CanchaModel(
      image: "lib/images/1.jpg",
      title: "Cancha Techada Biblos #1",
      price: "\$80.000 COP",
      horario: "7:00 AM - 10:00 PM",
      tipo: TipoCancha.cerrada,
      jugadores: "6 vs 6",
    ),
    CanchaModel(
      image: "lib/images/3.jpg",
      title: "Cancha Techada Biblos #2",
      price: "\$80.000 COP",
      horario: "7:00 AM - 10:00 PM",
      tipo: TipoCancha.cerrada,
      jugadores: "6 vs 6",
    ),
    CanchaModel(
      image: "lib/images/6.jpg",
      title: "Cancha Abierta Biblos #1",
      price: "\$50.000 COP",
      horario: "7:00 AM - 10:00 PM",
      tipo: TipoCancha.abierta,
      jugadores: "5 vs 5",
    ),
    CanchaModel(
      image: "lib/images/7.jpg",
      title: "Cancha Abierta Biblos #2",
      price: "\$50.000 COP",
      horario: "7:00 AM - 10:00 PM",
      tipo: TipoCancha.abierta,
      jugadores: "5 vs 5",
    ),
  ];

  List<CanchaModel> get canchas => _canchas;

  CanchaModel? obtenerCanchaPorTipo(TipoCancha tipo) {
    try {
      return _canchas.firstWhere((cancha) => cancha.tipo == tipo);
    } catch (e) {
      return null;
    }
  }

  void agregarCancha(CanchaModel cancha) {
    _canchas.add(cancha);
    notifyListeners();
  }

  void eliminarCancha(int index) {
    _canchas.removeAt(index);
    notifyListeners();
  }
}
