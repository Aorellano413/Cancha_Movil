// lib/controllers/sedes_controller.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/sede_model.dart';
import '../services/firestore_service.dart';

class SedesController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  
  List<SedeModel> _todasLasSedes = [];
  String _searchText = "";
  bool _isLoading = false;
  String? _error;
  
  // Variables para geolocalización
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String _ordenamiento = 'ninguno'; // 'ninguno', 'distancia', 'nombre'

  List<SedeModel> get sedes {
    List<SedeModel> resultado = _todasLasSedes;
    
    // Filtrar por búsqueda
    if (_searchText.isNotEmpty) {
      resultado = resultado.where((s) {
        final title = s.title.toLowerCase();
        final subtitle = s.subtitle.toLowerCase();
        return title.contains(_searchText) || subtitle.contains(_searchText);
      }).toList();
    }
    
    // Ordenar según criterio
    if (_ordenamiento == 'distancia' && _currentPosition != null) {
      resultado.sort((a, b) {
        final distA = a.distanceInKm ?? double.infinity;
        final distB = b.distanceInKm ?? double.infinity;
        return distA.compareTo(distB);
      });
    } else if (_ordenamiento == 'nombre') {
      resultado.sort((a, b) => a.title.compareTo(b.title));
    }
    
    return List.unmodifiable(resultado);
  }

  List<SedeModel> get customSedes =>
      _todasLasSedes.where((s) => s.isCustom).toList(growable: false);

  bool get isLoading => _isLoading;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get error => _error;
  String get ordenamiento => _ordenamiento;
  Position? get currentPosition => _currentPosition;

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
      
      // Intentar obtener coordenadas para sedes que no las tienen
      await _geocodificarSedesSinCoordenadas();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar sedes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Geocodificar sedes que no tienen coordenadas usando sus direcciones
  Future<void> _geocodificarSedesSinCoordenadas() async {
    for (int i = 0; i < _todasLasSedes.length; i++) {
      final sede = _todasLasSedes[i];
      
      // Si no tiene coordenadas, intentar geocodificar
      if (!sede.hasValidCoordinates() && sede.subtitle.isNotEmpty) {
        try {
          final locations = await locationFromAddress(sede.subtitle);
          
          if (locations.isNotEmpty) {
            final location = locations.first;
            _todasLasSedes[i] = sede.copyWith(
              latitude: location.latitude,
              longitude: location.longitude,
            );
            
            // Actualizar en Firestore si tiene ID
            if (sede.id != null) {
              await _firestore.actualizarSede(sede.id!, _todasLasSedes[i]);
            }
          }
        } catch (e) {
          debugPrint('Error geocodificando ${sede.title}: $e');
        }
      }
    }
  }

  /// Obtener ubicación actual del usuario y calcular distancias
  Future<void> obtenerUbicacionYCalcularDistancias() async {
    _isLoadingLocation = true;
    _error = null;
    notifyListeners();

    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permisos de ubicación denegados permanentemente');
      }

      // Obtener ubicación
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calcular distancias
      _calcularDistancias();
      
      _isLoadingLocation = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener ubicación: $e';
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  /// Calcular distancias desde la posición actual a todas las sedes
  void _calcularDistancias() {
    if (_currentPosition == null) return;

    for (int i = 0; i < _todasLasSedes.length; i++) {
      final sede = _todasLasSedes[i];
      
      if (sede.hasValidCoordinates()) {
        final distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          sede.latitude!,
          sede.longitude!,
        );
        
        _todasLasSedes[i] = sede.copyWith(
          distanceInKm: distanceInMeters / 1000,
        );
      }
    }
  }

  /// Cambiar tipo de ordenamiento
  void cambiarOrdenamiento(String tipo) {
    _ordenamiento = tipo;
    notifyListeners();
  }

  /// Ordenar por distancia (requiere ubicación previa)
  Future<void> ordenarPorDistancia() async {
    if (_currentPosition == null) {
      await obtenerUbicacionYCalcularDistancias();
    }
    cambiarOrdenamiento('distancia');
  }

  /// Escuchar cambios en tiempo real (opcional)
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