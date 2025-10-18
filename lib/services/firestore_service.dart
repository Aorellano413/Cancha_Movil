// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sede_model.dart';
import '../models/cancha_model.dart';
import '../models/reserva_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============ SEDES ============
  
  /// Obtener todas las sedes
  Stream<List<SedeModel>> getSedesStream() {
    return _db.collection('sedes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SedeModel.fromJson(data);
      }).toList();
    });
  }

  /// Obtener sedes como Future
  Future<List<SedeModel>> getSedes() async {
    final snapshot = await _db.collection('sedes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return SedeModel.fromJson(data);
    }).toList();
  }

  /// Agregar nueva sede
  Future<String> agregarSede(SedeModel sede) async {
    final docRef = await _db.collection('sedes').add(sede.toJson());
    return docRef.id;
  }

  /// Actualizar sede
  Future<void> actualizarSede(String sedeId, SedeModel sede) async {
    await _db.collection('sedes').doc(sedeId).update(sede.toJson());
  }

  /// Eliminar sede
  Future<void> eliminarSede(String sedeId) async {
    await _db.collection('sedes').doc(sedeId).delete();
  }

  // ============ CANCHAS ============

  /// Obtener canchas por sede
  Stream<List<CanchaModel>> getCanchasPorSedeStream(String sedeId) {
    return _db
        .collection('canchas')
        .where('sedeId', isEqualTo: sedeId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CanchaModel.fromJson(data);
      }).toList();
    });
  }

  /// Obtener canchas por sede como Future
  Future<List<CanchaModel>> getCanchasPorSede(String sedeId) async {
    final snapshot = await _db
        .collection('canchas')
        .where('sedeId', isEqualTo: sedeId)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return CanchaModel.fromJson(data);
    }).toList();
  }

  /// Agregar nueva cancha
  Future<String> agregarCancha(CanchaModel cancha, String sedeId) async {
    final data = cancha.toJson();
    data['sedeId'] = sedeId;
    final docRef = await _db.collection('canchas').add(data);
    return docRef.id;
  }

  /// Actualizar cancha
  Future<void> actualizarCancha(String canchaId, CanchaModel cancha) async {
    await _db.collection('canchas').doc(canchaId).update(cancha.toJson());
  }

  /// Eliminar cancha
  Future<void> eliminarCancha(String canchaId) async {
    await _db.collection('canchas').doc(canchaId).delete();
  }

  // ============ RESERVAS ============

  /// Crear nueva reserva
  Future<String> crearReserva(ReservaModel reserva, String canchaId, String sedeId) async {
    final data = reserva.toJson();
    data['canchaId'] = canchaId;
    data['sedeId'] = sedeId;
    data['estado'] = 'pendiente';
    data['createdAt'] = FieldValue.serverTimestamp();
    
    final docRef = await _db.collection('reservas').add(data);
    return docRef.id;
  }

  /// Obtener todas las reservas
  Stream<List<Map<String, dynamic>>> getReservasStream() {
    return _db
        .collection('reservas')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Obtener reservas por estado
  Stream<List<Map<String, dynamic>>> getReservasPorEstadoStream(String estado) {
    return _db
        .collection('reservas')
        .where('estado', isEqualTo: estado)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Obtener reservas por usuario (correo)
  Future<List<Map<String, dynamic>>> getReservasPorUsuario(String correo) async {
    final snapshot = await _db
        .collection('reservas')
        .where('correoElectronico', isEqualTo: correo)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Actualizar estado de reserva
  Future<void> actualizarEstadoReserva(String reservaId, String nuevoEstado) async {
    await _db.collection('reservas').doc(reservaId).update({
      'estado': nuevoEstado,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Eliminar reserva
  Future<void> eliminarReserva(String reservaId) async {
    await _db.collection('reservas').doc(reservaId).delete();
  }

  /// ✅ Verificar disponibilidad SIN índice compuesto
Future<bool> verificarDisponibilidad({
  required String canchaId,
  required DateTime fecha,
  required String horaReserva,
}) async {
  try {
    // Crear timestamps para el inicio y fin del día
    final inicioDelDia = DateTime(fecha.year, fecha.month, fecha.day);
    final finDelDia = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

    // ✅ Paso 1: Obtener todas las reservas de la cancha (sin filtrar por fecha)
    final snapshot = await _db
        .collection('reservas')
        .where('canchaId', isEqualTo: canchaId)
        .get();

    // ✅ Paso 2: Filtrar manualmente por fecha, hora y estado
    for (var doc in snapshot.docs) {
      final data = doc.data();
      
      // Extraer datos del documento
      final Timestamp? fechaTimestamp = data['fechaReserva'];
      final String? horaDoc = data['horaReserva'];
      final String? estadoDoc = data['estado'];

      // Verificar si tiene los campos necesarios
      if (fechaTimestamp == null || horaDoc == null || estadoDoc == null) {
        continue;
      }

      // Convertir Timestamp a DateTime
      final fechaDoc = fechaTimestamp.toDate();

      // Verificar si es el mismo día
      final mismaFecha = fechaDoc.year == fecha.year &&
                        fechaDoc.month == fecha.month &&
                        fechaDoc.day == fecha.day;

      // Verificar si la hora y el estado coinciden
      if (mismaFecha && 
          horaDoc == horaReserva && 
          (estadoDoc == 'pendiente' || estadoDoc == 'confirmada' || estadoDoc == 'pagado')) {
        // Ya existe una reserva para esa fecha y hora
        return false;
      }
    }

    // No hay conflictos, está disponible
    return true;
  } catch (e) {
    print('❌ Error al verificar disponibilidad: $e');
    // En caso de error, por seguridad retornamos false
    return false;
  }
}

  /// Obtener estadísticas del dashboard
  Future<Map<String, dynamic>> getEstadisticasDashboard() async {
    final reservasSnapshot = await _db.collection('reservas').get();
    final sedesSnapshot = await _db.collection('sedes').get();
    final canchasSnapshot = await _db.collection('canchas').get();

    int pendientes = 0;
    int pagadas = 0;
    int canceladas = 0;

    for (var doc in reservasSnapshot.docs) {
      final estado = doc.data()['estado'] ?? 'pendiente';
      if (estado == 'pendiente') pendientes++;
      if (estado == 'pagado') pagadas++;
      if (estado == 'cancelado') canceladas++;
    }

    return {
      'totalReservas': reservasSnapshot.docs.length,
      'totalSedes': sedesSnapshot.docs.length,
      'totalCanchas': canchasSnapshot.docs.length,
      'reservasPendientes': pendientes,
      'reservasPagadas': pagadas,
      'reservasCanceladas': canceladas,
    };
  }

  /// Obtener reservas con información completa (sede y cancha)
  Future<List<Map<String, dynamic>>> getReservasCompletas() async {
    final reservasSnapshot = await _db
        .collection('reservas')
        .orderBy('createdAt', descending: true)
        .get();

    List<Map<String, dynamic>> reservasCompletas = [];

    for (var doc in reservasSnapshot.docs) {
      final reservaData = doc.data();
      reservaData['id'] = doc.id;

      // Obtener información de la sede
      if (reservaData['sedeId'] != null) {
        final sedeDoc = await _db.collection('sedes').doc(reservaData['sedeId']).get();
        if (sedeDoc.exists) {
          reservaData['sede'] = sedeDoc.data();
        }
      }

      // Obtener información de la cancha
      if (reservaData['canchaId'] != null) {
        final canchaDoc = await _db.collection('canchas').doc(reservaData['canchaId']).get();
        if (canchaDoc.exists) {
          reservaData['cancha'] = canchaDoc.data();
        }
      }

      reservasCompletas.add(reservaData);
    }

    return reservasCompletas;
  }
}