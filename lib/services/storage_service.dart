// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> subirImagenSede({
    required String sedeId,
    required dynamic imageFile, 
  }) async {
    try {
      final String fileName = 'sede_${sedeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('sedes/$fileName');

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
      
      print('✅ Imagen de sede subida: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error al subir imagen de sede: $e');
      rethrow;
    }
  }

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
    
    }
  }

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

  bool esUrlFirebase(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }

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