// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir imagen de sede
  /// Retorna la URL de descarga
  Future<String> subirImagenSede({
    required String sedeId,
    required dynamic imageFile, // XFile o File
  }) async {
    try {
      final String fileName = 'sede_${sedeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('sedes/$fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        // Para web, usar bytes
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Para móvil, usar File
        final file = File(imageFile.path);
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Imagen de sede subida: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error al subir imagen de sede: $e');
      rethrow;
    }
  }

  /// Subir imagen de cancha
  /// Retorna la URL de descarga
  Future<String> subirImagenCancha({
    required String canchaId,
    required dynamic imageFile,
  }) async {
    try {
      final String fileName = 'cancha_${canchaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('canchas/$fileName');

      UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        final file = File(imageFile.path);
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Imagen de cancha subida: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error al subir imagen de cancha: $e');
      rethrow;
    }
  }

  /// Eliminar imagen por URL
  Future<void> eliminarImagen(String imageUrl) async {
    try {
      if (imageUrl.isEmpty || !imageUrl.contains('firebase')) {
        print('⚠️ URL no es de Firebase Storage, no se eliminará');
        return;
      }

      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Imagen eliminada: $imageUrl');
    } catch (e) {
      print('❌ Error al eliminar imagen: $e');
      // No lanzamos el error para que no interrumpa el flujo
    }
  }

  /// Eliminar todas las imágenes de una sede
  Future<void> eliminarImagenesSede(String sedeId) async {
    try {
      final Reference sedesRef = _storage.ref().child('sedes');
      final ListResult result = await sedesRef.listAll();

      for (var item in result.items) {
        if (item.name.contains('sede_$sedeId')) {
          await item.delete();
          print('✅ Imagen de sede eliminada: ${item.name}');
        }
      }
    } catch (e) {
      print('❌ Error al eliminar imágenes de sede: $e');
    }
  }

  /// Eliminar todas las imágenes de una cancha
  Future<void> eliminarImagenesCancha(String canchaId) async {
    try {
      final Reference canchasRef = _storage.ref().child('canchas');
      final ListResult result = await canchasRef.listAll();

      for (var item in result.items) {
        if (item.name.contains('cancha_$canchaId')) {
          await item.delete();
          print('✅ Imagen de cancha eliminada: ${item.name}');
        }
      }
    } catch (e) {
      print('❌ Error al eliminar imágenes de cancha: $e');
    }
  }

  /// Validar si una URL es de Firebase Storage
  bool esUrlFirebase(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }

  /// Obtener el tamaño de una imagen en Firebase Storage
  Future<int> obtenerTamanoImagen(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      print('❌ Error al obtener tamaño de imagen: $e');
      return 0;
    }
  }
}