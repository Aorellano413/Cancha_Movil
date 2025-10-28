// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math' show cos, sqrt, asin, pi, sin;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationService {
  Future<Position?> obtenerUbicacionActual() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados');
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

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error al obtener ubicación: $e');
      return null;
    }
  }

  /// Geocodificar usando OpenStreetMap Nominatim (funciona en Web)
  Future<Map<String, double>?> convertirDireccionACoordenadas(String direccion) async {
    if (kIsWeb) {
      // Usar API HTTP para Web
      return await _geocodificarConNominatim(direccion);
    } else {
      // Usar paquete nativo para móvil
      return await _geocodificarNativo(direccion);
    }
  }

  /// Geocodificación usando OpenStreetMap Nominatim API (Web compatible)
  Future<Map<String, double>?> _geocodificarConNominatim(String direccion) async {
    try {
      final direccionEncoded = Uri.encodeComponent(direccion);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$direccionEncoded&format=json&limit=1'
      );
      
      final response = await http.get(
        url,
        headers: {'User-Agent': 'ReservaSports/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'latitud': double.parse(data[0]['lat']),
            'longitud': double.parse(data[0]['lon']),
          };
        }
      }
      return null;
    } catch (e) {
      print('Error en geocodificación Nominatim: $e');
      return null;
    }
  }

  /// Geocodificación nativa (solo móvil)
  Future<Map<String, double>?> _geocodificarNativo(String direccion) async {
    try {
      List<Location> locations = await locationFromAddress(direccion);
      
      if (locations.isNotEmpty) {
        return {
          'latitud': locations.first.latitude,
          'longitud': locations.first.longitude,
        };
      }
      return null;
    } catch (e) {
      print('Error al geocodificar dirección "$direccion": $e');
      return null;
    }
  }

  double calcularDistancia(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    const double radioTierra = 6371;
    
    double dLat = _gradosARadianes(lat2 - lat1);
    double dLon = _gradosARadianes(lon2 - lon1);
    
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
               cos(_gradosARadianes(lat1)) * 
               cos(_gradosARadianes(lat2)) *
               (sin(dLon / 2) * sin(dLon / 2));
    
    double c = 2 * asin(sqrt(a));
    
    return radioTierra * c;
  }

  double _gradosARadianes(double grados) {
    return grados * (pi / 180);
  }

  String formatearDistancia(double distanciaKm) {
    if (distanciaKm < 1) {
      return '${(distanciaKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanciaKm.toStringAsFixed(1)} km';
    }
  }
}