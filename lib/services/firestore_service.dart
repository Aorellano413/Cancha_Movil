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

  /// Verificar disponibilidad de cancha en fecha y hora específica
  Future<bool> verificarDisponibilidad({
    required String canchaId,
    required DateTime fecha,
    required String horaReserva,
  }) async {
    final inicioDelDia = DateTime(fecha.year, fecha.month, fecha.day);
    final finDelDia = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

    final snapshot = await _db
        .collection('reservas')
        .where('canchaId', isEqualTo: canchaId)
        .where('fechaReserva', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDelDia))
        .where('fechaReserva', isLessThanOrEqualTo: Timestamp.fromDate(finDelDia))
        .where('horaReserva', isEqualTo: horaReserva)
        .where('estado', whereIn: ['pendiente', 'confirmada'])
        .get();

    return snapshot.docs.isEmpty;
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