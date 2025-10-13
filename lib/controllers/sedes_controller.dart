import 'package:flutter/material.dart';
import '../models/sede_model.dart';

class SedesController extends ChangeNotifier {
  final List<SedeModel> _todasLasSedes = [
     SedeModel(
      imagePath: "lib/images/jugada.jpg", 
      title: "Sede - La Jugada Principal",
      subtitle: "Mayales, Valledupar",
      price: "\$80.000",
      tag: "Día - Noche",
    ),
    SedeModel(
      imagePath: "lib/images/sede2.jpg", 
      title: "Sede - La Jugada Secundaria",
      subtitle: "Mayales, Valledupar",
      price: "\$70.000",
      tag: "Día - Noche",
    ),
    SedeModel(
      imagePath: "lib/images/biblos.jpg",
      title: "Sede - Biblos",
      subtitle: "Sabanas, Valledupar",
      price: "\$70.000",
      tag: "Día - Noche",
    ),
    SedeModel(
      imagePath: "lib/images/fortin.jpg", 
      title: "Sede - El Fortín",
      subtitle: "Cra 9 #14A-22, Valledupar",
      price: "\$80.000",
      tag: "Día - Noche",
    ),
  ];

  String _searchText = "";

  List<SedeModel> get sedes {
    if (_searchText.isEmpty) {
      return _todasLasSedes;
    }
    return _todasLasSedes.where((sede) {
      final title = sede.title.toLowerCase();
      final subtitle = sede.subtitle.toLowerCase();
      return title.contains(_searchText) || subtitle.contains(_searchText);
    }).toList();
  }

  void buscarSedes(String query) {
    _searchText = query.toLowerCase();
    notifyListeners();
  }

  void agregarSede(SedeModel sede) {
    _todasLasSedes.add(sede);
    notifyListeners();
  }

  void eliminarSede(int index) {
    _todasLasSedes.removeAt(index);
    notifyListeners();
  }
}
