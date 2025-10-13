import 'package:flutter/material.dart';
import '../models/cancha_model.dart';

class CanchasFortinController extends ChangeNotifier {
  final List<CanchaModel> _canchas = [
    CanchaModel(
      image: "lib/images/fsintecho2.jpg",
      title: "Cancha Abierta",
      horario: "8:00 AM - 10:00 PM",
      price: "\$70.000",
      tipo: TipoCancha.sintetica,
    ),
    CanchaModel(
      image: "lib/images/ftecho.jpg",
      title: "Cancha Techada",
      horario: "7:00 AM - 9:00 PM",
      price: "\$60.000",
      tipo: TipoCancha.natural,
    ),
  ];

  List<CanchaModel> get canchas => _canchas;
}
