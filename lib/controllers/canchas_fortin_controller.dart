import 'package:flutter/material.dart';
import '../models/cancha_model.dart';

class CanchasFortinController extends ChangeNotifier {
  final List<CanchaModel> _canchas = [
    CanchaModel(
      image: "lib/images/fsintecho2.jpg",
      title: "Cancha Abierta",
      horario: "7:00 AM - 11:00 PM",
      price: "\$70.000 COP",
      jugadores: "6 vs 6",
      tipo: TipoCancha.sintetica,
    ),
    CanchaModel(
      image: "lib/images/ftecho.jpg",
      title: "Cancha Techada",
      horario: "7:00 AM - 11:00 PM",
      price: "\$60.000 COP",
      jugadores: "5 vs 5",
      tipo: TipoCancha.natural,
    ),
  ];

  List<CanchaModel> get canchas => _canchas;
}
