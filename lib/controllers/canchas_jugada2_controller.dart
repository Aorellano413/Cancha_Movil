import 'package:flutter/material.dart';
import '../models/cancha_model.dart';

class CanchasJugada2Controller extends ChangeNotifier {
  final List<CanchaModel> _canchas = [
    CanchaModel(
      image: "lib/images/sintecho.jpg",
      title: "Cancha Abirta #1",
      horario: "7:00 AM - 10:00 PM",
      price: "\$70.000 / hora",
      tipo:TipoCancha.cerrada,
    ),
    CanchaModel(
      image: "lib/images/j2.jpg",
      title: "Cancha  Abierta #2",
      horario: "7:00 AM - 10:00 PM",
      price: "\$70.000 / hora",
      tipo: TipoCancha.cerrada,
    ),
    CanchaModel(
      image: "lib/images/j3.jpg",
      title: "Cancha  Abierta #3",
      horario: "7:00 AM - 10:00 PM",
      price: "\$70.000 / hora",
      tipo: TipoCancha.cerrada,
    ),
  ];

  List<CanchaModel> get canchas => _canchas;
}
