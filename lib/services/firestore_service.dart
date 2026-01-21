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

  Stream<List<SedeModel>> getSedesStream() {
    return _db.collection('sedes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SedeModel.fromJson(data);
      }).toList();
    });
  }

  Future<List<SedeModel>> getSedes() async {
    final snapshot = await _db.collection('sedes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return SedeModel.fromJson(data);
    }).toList();
  }

  Future<String> agregarSede(SedeModel sede) async {
    final docRef = await _db.collection('sedes').add(sede.toJson());
    return docRef.id;
  }

  Future<void> actualizarSede(String sedeId, SedeModel sede) async {
    await _db.collection('sedes').doc(sedeId).update(sede.toJson());
  }

  Future<void> eliminarSede(String sedeId) async {
    await _db.collection('sedes').doc(sedeId).delete();
  }

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

  Future<String> agregarCancha(CanchaModel cancha, String sedeId) async {
    final data = cancha.toJson();
    data['sedeId'] = sedeId;
    final docRef = await _db.collection('canchas').add(data);
    return docRef.id;
  }
  Future<void> actualizarCancha(String canchaId, CanchaModel cancha) async {
    await _db.collection('canchas').doc(canchaId).update(cancha.toJson());
  }

  Future<void> eliminarCancha(String canchaId) async {
    await _db.collection('canchas').doc(canchaId).delete();
  }

  Future<String> crearReserva(ReservaModel reserva, String canchaId, String sedeId) async {
    final data = reserva.toJson();
    data['canchaId'] = canchaId;
    data['sedeId'] = sedeId;
    data['estado'] = 'pendiente';
    data['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _db.collection('reservas').add(data);
    return docRef.id;
  }

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

  Future<void> actualizarEstadoReserva(String reservaId, String nuevoEstado) async {
    await _db.collection('reservas').doc(reservaId).update({
      'estado': nuevoEstado,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> eliminarReserva(String reservaId) async {
    await _db.collection('reservas').doc(reservaId).delete();
  }

  Future<bool> verificarDisponibilidad({
    required String canchaId,
    required DateTime fecha,
    required String horaReserva,
  }) async {
    try {

      final inicioDelDia = DateTime(fecha.year, fecha.month, fecha.day);
      final finDelDia = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59);

      final snapshot = await _db
          .collection('reservas')
          .where('canchaId', isEqualTo: canchaId)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final Timestamp? fechaTimestamp = data['fechaReserva'];
        final String? horaDoc = data['horaReserva'];
        final String? estadoDoc = data['estado'];

        if (fechaTimestamp == null || horaDoc == null || estadoDoc == null) {
          continue;
        }

        final fechaDoc = fechaTimestamp.toDate();

        final mismaFecha = fechaDoc.year == fecha.year &&
                          fechaDoc.month == fecha.month &&
                          fechaDoc.day == fecha.day;

        if (mismaFecha &&
            horaDoc == horaReserva &&
            (estadoDoc == 'pendiente' || estadoDoc == 'confirmada' || estadoDoc == 'pagado')) {

          return false;
        }
      }


      return true;
    } catch (e) {

      print('❌ Error al verificar disponibilidad: $e');

      return false;
    }
  }

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

  Future<Map<String, dynamic>> getEstadisticasPorSede(String sedeId) async {
    try {
      final reservasSnapshot = await _db
          .collection('reservas')
          .where('sedeId', isEqualTo: sedeId)
          .get();

      final canchasSnapshot = await _db
          .collection('canchas')
          .where('sedeId', isEqualTo: sedeId)
          .get();

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
        'totalCanchas': canchasSnapshot.docs.length,
        'totalSedes': 1,
        'reservasPendientes': pendientes,
        'reservasPagadas': pagadas,
        'reservasCanceladas': canceladas,
      };
    } catch (e) {
      print('Error en getEstadisticasPorSede: $e');
      rethrow;
    }
  }


  Future<List<Map<String, dynamic>>> getReservasCompletas() async {
    try {
      final reservasSnapshot = await _db
          .collection('reservas')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> reservasCompletas = [];

      for (var doc in reservasSnapshot.docs) {
        final reservaData = doc.data();
        reservaData['id'] = doc.id;

        if (reservaData['sedeId'] != null) {
          try {
            final sedeDoc = await _db
                .collection('sedes')
                .doc(reservaData['sedeId'])
                .get();

            if (sedeDoc.exists) {
              reservaData['sede'] = sedeDoc.data();
            } else {
              reservaData['sede'] = {
                'title': 'Sede no encontrada',
                'subtitle': '',
              };
            }
          } catch (e) {
            print('Error al obtener sede: $e');
            reservaData['sede'] = {
              'title': 'Sin acceso',
              'subtitle': '',
            };
          }
        }

        if (reservaData['canchaId'] != null) {
          try {
            final canchaDoc = await _db
                .collection('canchas')
                .doc(reservaData['canchaId'])
                .get();

            if (canchaDoc.exists) {
              reservaData['cancha'] = canchaDoc.data();
            } else {
              reservaData['cancha'] = {
                'title': 'Cancha no encontrada',
                'price': '\$0',
              };
            }
          } catch (e) {
            print('Error al obtener cancha: $e');
            reservaData['cancha'] = {
              'title': 'Sin acceso',
              'price': '\$0',
            };
          }
        }

        reservasCompletas.add(reservaData);
      }

      return reservasCompletas;
    } catch (e) {
      print('Error en getReservasCompletas: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getReservasCompletasPorSede(String sedeId) async {
    try {
      final reservasSnapshot = await _db
          .collection('reservas')
          .where('sedeId', isEqualTo: sedeId)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> reservasCompletas = [];

      for (var doc in reservasSnapshot.docs) {
        final reservaData = doc.data();
        reservaData['id'] = doc.id;

        if (reservaData['sedeId'] != null) {
          try {
            final sedeDoc = await _db
                .collection('sedes')
                .doc(reservaData['sedeId'])
                .get();
            if (sedeDoc.exists) {
              reservaData['sede'] = sedeDoc.data();
            }
          } catch (e) {
            print('Error al obtener sede: $e');
          }
        }

        if (reservaData['canchaId'] != null) {
          try {
            final canchaDoc = await _db
                .collection('canchas')
                .doc(reservaData['canchaId'])
                .get();
            if (canchaDoc.exists) {
              reservaData['cancha'] = canchaDoc.data();
            }
          } catch (e) {
            print('Error al obtener cancha: $e');
          }
        }

        reservasCompletas.add(reservaData);
      }

      return reservasCompletas;
    } catch (e) {
      print('Error en getReservasCompletasPorSede: $e');
      rethrow;
    }
  }
}