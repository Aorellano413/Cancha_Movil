import 'package:flutter/material.dart';
import '../models/cancha_model.dart';

class CanchasController extends ChangeNotifier {
  final List<CanchaModel> _canchas = [
    CanchaModel(
      image: "lib/images/techo.jpg",
      title: "Cancha Techada",
      price: "\$80.000 COP",
      horario: "7:00 AM - 11:00 PM",
      jugadores: "5 vs 5",
      tipo: TipoCancha.cerrada,
    ),

    CanchaModel(
      image: "lib/images/jsintecho.jpg",
      title: "Cancha abierta",
      price: "\$60.000 COP",
      horario: "7:00 AM - 11:00 PM",
      jugadores: "5 vs 5",
      tipo: TipoCancha.cerrada,
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
