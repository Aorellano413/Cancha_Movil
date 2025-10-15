// lib/controllers/sedes_controller.dart
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
      isCustom: false,
    ),
    SedeModel(
      imagePath: "lib/images/sede2.jpg",
      title: "Sede - La Jugada Secundaria",
      subtitle: "Mayales, Valledupar",
      price: "\$70.000",
      tag: "Día - Noche",
      isCustom: false,
    ),
    SedeModel(
      imagePath: "lib/images/biblos.jpg",
      title: "Sede - Biblos",
      subtitle: "Sabanas, Valledupar",
      price: "\$70.000",
      tag: "Día - Noche",
      isCustom: false,
    ),
    SedeModel(
      imagePath: "lib/images/fortin.jpg",
      title: "Sede - El Fortín",
      subtitle: "Cra 9 #14A-22, Valledupar",
      price: "\$80.000",
      tag: "Día - Noche",
      isCustom: false,
    ),
  ];

  String _searchText = "";

  
  List<SedeModel> get sedes {
    if (_searchText.isEmpty) return List.unmodifiable(_todasLasSedes);
    return _todasLasSedes.where((s) {
      final title = s.title.toLowerCase();
      final subtitle = s.subtitle.toLowerCase();
      return title.contains(_searchText) || subtitle.contains(_searchText);
    }).toList();
  }


  List<SedeModel> get customSedes =>
      _todasLasSedes.where((s) => s.isCustom).toList(growable: false);

  void buscarSedes(String query) {
    _searchText = query.toLowerCase();
    notifyListeners();
  }

  void agregarSede(SedeModel sede) {
    _todasLasSedes.add(sede.copyWith(isCustom: true));
    notifyListeners();
  }

  
  void actualizarSedeCustom(int customIndex, SedeModel updated) {
 
    int count = -1;
    for (int i = 0; i < _todasLasSedes.length; i++) {
      if (_todasLasSedes[i].isCustom) {
        count++;
        if (count == customIndex) {
          _todasLasSedes[i] = updated.copyWith(isCustom: true);
          notifyListeners();
          return;
        }
      }
    }
  }

  void eliminarSedeCustom(int customIndex) {
    int count = -1;
    for (int i = 0; i < _todasLasSedes.length; i++) {
      if (_todasLasSedes[i].isCustom) {
        count++;
        if (count == customIndex) {
          _todasLasSedes.removeAt(i);
          notifyListeners();
          return;
        }
      }
    }
  }
}
