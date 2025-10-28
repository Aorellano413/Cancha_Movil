// lib/controllers/sedes_controller.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/sede_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';

// ⭐ CLASE AUXILIAR PARA ASOCIAR SEDE CON DISTANCIA
class SedeConDistancia {
  final SedeModel sede;
  final double? distanciaKm;

  SedeConDistancia({required this.sede, this.distanciaKm});
}

class SedesController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();
  final LocationService _location = LocationService();
  
  List<SedeModel> _todasLasSedes = [];
  List<SedeConDistancia> _sedesConDistancia = [];
  String _searchText = "";
  bool _isLoading = false;
  bool _buscandoUbicacion = false;
  String? _error;
  Position? _ubicacionUsuario;
  bool _ordenarPorDistancia = false;

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

  // ⭐ NUEVO GETTER PARA SEDES CON DISTANCIA
  List<SedeConDistancia> get sedesConDistancia {
    if (_ordenarPorDistancia && _sedesConDistancia.isNotEmpty) {
      return _sedesConDistancia;
    }
    // Si no está ordenando por distancia, devolver sedes normales sin distancia
    return _todasLasSedes.map((sede) => 
      SedeConDistancia(sede: sede, distanciaKm: null)
    ).toList();
  }

  bool get isLoading => _isLoading;
  bool get buscandoUbicacion => _buscandoUbicacion;
  String? get error => _error;
  Position? get ubicacionUsuario => _ubicacionUsuario;
  bool get ordenarPorDistancia => _ordenarPorDistancia;

  SedesController() {
    cargarSedes();
  }

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

  // ⭐ NUEVO MÉTODO: Buscar sedes cercanas
  Future<void> buscarSedesCercanas() async {
    _buscandoUbicacion = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Obtener ubicación del usuario
      _ubicacionUsuario = await _location.obtenerUbicacionActual();
      
      if (_ubicacionUsuario == null) {
        _error = 'No se pudo obtener tu ubicación. Verifica los permisos.';
        _buscandoUbicacion = false;
        notifyListeners();
        return;
      }

      // 2. Calcular distancia para cada sede
      List<SedeConDistancia> sedesConDist = [];
      
      for (var sede in _todasLasSedes) {
        double? distancia;
        
        // Si la sede ya tiene coordenadas guardadas
        if (sede.tieneCoordenadasValidas()) {
          distancia = _location.calcularDistancia(
            _ubicacionUsuario!.latitude,
            _ubicacionUsuario!.longitude,
            sede.latitud!,
            sede.longitud!,
          );
        } else {
          // Geocodificar la dirección (subtitle)
          final coords = await _location.convertirDireccionACoordenadas(
            sede.subtitle,
          );
          
          if (coords != null) {
            // Actualizar la sede con las coordenadas obtenidas
            final sedeActualizada = sede.copyWith(
              latitud: coords['latitud'],
              longitud: coords['longitud'],
            );
            
            // Guardar coordenadas en Firestore para búsquedas futuras
            if (sede.id != null) {
              await _firestore.actualizarSede(sede.id!, sedeActualizada);
              // Actualizar en la lista local
              final index = _todasLasSedes.indexWhere((s) => s.id == sede.id);
              if (index != -1) {
                _todasLasSedes[index] = sedeActualizada;
              }
            }
            
            distancia = _location.calcularDistancia(
              _ubicacionUsuario!.latitude,
              _ubicacionUsuario!.longitude,
              coords['latitud']!,
              coords['longitud']!,
            );
          }
        }
        
        sedesConDist.add(SedeConDistancia(
          sede: sede,
          distanciaKm: distancia,
        ));
      }

      // 3. Ordenar por distancia (más cercanas primero)
      sedesConDist.sort((a, b) {
        if (a.distanciaKm == null) return 1;
        if (b.distanciaKm == null) return -1;
        return a.distanciaKm!.compareTo(b.distanciaKm!);
      });

      _sedesConDistancia = sedesConDist;
      _ordenarPorDistancia = true;
      _buscandoUbicacion = false;
      notifyListeners();
      
    } catch (e) {
      _error = 'Error al buscar sedes cercanas: $e';
      _buscandoUbicacion = false;
      notifyListeners();
    }
  }

  // ⭐ NUEVO MÉTODO: Resetear orden
  void resetearOrden() {
    _ordenarPorDistancia = false;
    _sedesConDistancia = [];
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