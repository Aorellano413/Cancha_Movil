// lib/controllers/sedes_controller.dart
import 'package:flutter/material.dart';
import '../models/sede_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class SedesController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  
  List<SedeModel> _todasLasSedes = [];
  String _searchText = "";
  bool _isLoading = false;
  String? _error;

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

  bool get isLoading => _isLoading;
  String? get error => _error;

  SedesController() {
    cargarSedes();
  }

  /// Cargar sedes desde Firestore
  Future<void> cargarSedes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todasLasSedes = await _firestore.getSedes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar sedes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  void escucharSedes() {
    _firestore.getSedesStream().listen(
      (sedes) {
        _todasLasSedes = sedes;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error al escuchar sedes: $error';
        notifyListeners();
      },
    );
  }

  void buscarSedes(String query) {
    _searchText = query.toLowerCase();
    notifyListeners();
  }

  Future<void> agregarSede(SedeModel sede) async {
    try {
      final sedeConTag = sede.copyWith(isCustom: true, tag: "Día - Noche");
      final id = await _firestore.agregarSede(sedeConTag);
      _todasLasSedes.add(sedeConTag.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar sede: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> actualizarSedeCustom(int customIndex, SedeModel updated) async {
    try {
      int count = -1;
      for (int i = 0; i < _todasLasSedes.length; i++) {
        if (_todasLasSedes[i].isCustom) {
          count++;
          if (count == customIndex) {
            final sedeId = _todasLasSedes[i].id;
            if (sedeId == null) {
              throw Exception('Sede sin ID');
            }
            
            final sedeActualizada = updated.copyWith(
              id: sedeId,
              isCustom: true,
              tag: "Día - Noche",
            );
            
            await _firestore.actualizarSede(sedeId, sedeActualizada);
            _todasLasSedes[i] = sedeActualizada;
            notifyListeners();
            return;
          }
        }
      }
    } catch (e) {
      _error = 'Error al actualizar sede: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarSedeCustom(int customIndex) async {
    try {
      int count = -1;
      for (int i = 0; i < _todasLasSedes.length; i++) {
        if (_todasLasSedes[i].isCustom) {
          count++;
          if (count == customIndex) {
            final sedeId = _todasLasSedes[i].id;
            if (sedeId == null) {
              throw Exception('Sede sin ID');
            }
            
            // ✅ AGREGAR ESTAS 4 LÍNEAS
            final imagePath = _todasLasSedes[i].imagePath;
            if (imagePath.isNotEmpty && _storage.esUrlFirebase(imagePath)) {
              await _storage.eliminarImagen(imagePath);
            }
            
            await _firestore.eliminarSede(sedeId);
            _todasLasSedes.removeAt(i);
            notifyListeners();
            return;
          }
        }
      }
    } catch (e) {
      _error = 'Error al eliminar sede: $e';
      notifyListeners();
      rethrow;
    }
  }
  SedeModel? obtenerSedePorId(String sedeId) {
    try {
      return _todasLasSedes.firstWhere((s) => s.id == sedeId);
    } catch (e) {
      return null;
    }
  }
}