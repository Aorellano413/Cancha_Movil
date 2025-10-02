

import 'package:flutter/material.dart';
import '../models/cancha_model.dart';

class CanchasController extends ChangeNotifier {
  final List<CanchaModel> _canchas = [
    CanchaModel(
      image: "assets/images/cancha1.jpg",
      title: "Cancha Techada",
      price: "\$80.000 COP",
      horario: "6:00 AM - 11:00 PM",
      tipo: TipoCancha.cerrada,
    ),
    CanchaModel(
      image: "assets/images/cancha2.jpg",
      title: "Cancha Abierta",
      price: "\$70.000 COP",
      horario: "6:00 AM - 11:00 PM",
      tipo: TipoCancha.abierta,
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