// lib/utils/populate_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PopulateFirestore {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> poblarDatosIniciales() async {
    print('🔄 Iniciando población de datos...');

    // Verificar si ya hay datos
    final sedesSnapshot = await _db.collection('sedes').limit(1).get();
    if (sedesSnapshot.docs.isNotEmpty) {
      print('✅ Ya existen datos en la base de datos');
      print('ℹ️  Si deseas repoblar, primero ejecuta limpiarBaseDatos()');
      return;
    }

    try {
      // Crear sedes
      final sedes = await _crearSedes();
      
      // Crear canchas para cada sede
      await _crearCanchas(sedes);

      print('✅ Datos iniciales poblados exitosamente!');
      print('📊 Total sedes creadas: ${sedes.length}');
    } catch (e) {
      print('❌ Error al poblar datos: $e');
      rethrow;
    }
  }

  static Future<Map<String, String>> _crearSedes() async {
    final sedesIds = <String, String>{};

    print('📍 Creando sedes...');

    // Sede La Jugada Principal
    final jugadaRef = await _db.collection('sedes').add({
      'imagePath': 'lib/images/jugada.jpg',
      'title': 'Sede - La Jugada Principal',
      'subtitle': 'Mayales, Valledupar',
      'price': '\$80.000',
      'tag': 'Día - Noche',
      'isCustom': false,
    });
    sedesIds['jugada'] = jugadaRef.id;
    print('  ✓ La Jugada Principal');

    // Sede La Jugada Secundaria
    final jugada2Ref = await _db.collection('sedes').add({
      'imagePath': 'lib/images/sede2.jpg',
      'title': 'Sede - La Jugada Secundaria',
      'subtitle': 'Mayales, Valledupar',
      'price': '\$70.000',
      'tag': 'Día - Noche',
      'isCustom': false,
    });
    sedesIds['jugada2'] = jugada2Ref.id;
    print('  ✓ La Jugada Secundaria');

    // Sede Biblos
    final biblosRef = await _db.collection('sedes').add({
      'imagePath': 'lib/images/biblos.jpg',
      'title': 'Sede - Biblos',
      'subtitle': 'Sabanas, Valledupar',
      'price': '\$70.000',
      'tag': 'Día - Noche',
      'isCustom': false,
    });
    sedesIds['biblos'] = biblosRef.id;
    print('  ✓ Biblos');

    // Sede El Fortín
    final fortinRef = await _db.collection('sedes').add({
      'imagePath': 'lib/images/fortin.jpg',
      'title': 'Sede - El Fortín',
      'subtitle': 'Cra 9 #14A-22, Valledupar',
      'price': '\$80.000',
      'tag': 'Día - Noche',
      'isCustom': false,
    });
    sedesIds['fortin'] = fortinRef.id;
    print('  ✓ El Fortín');

    print('✅ ${sedesIds.length} sedes creadas');
    return sedesIds;
  }

  static Future<void> _crearCanchas(Map<String, String> sedesIds) async {
    print('⚽ Creando canchas...');
    int totalCanchas = 0;

    // Canchas La Jugada Principal
    print('  📍 La Jugada Principal:');
    await _db.collection('canchas').add({
      'sedeId': sedesIds['jugada'],
      'image': 'lib/images/techo.jpg',
      'title': 'Cancha Techada',
      'price': '\$80.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'cerrada',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Techada');
    totalCanchas++;

    await _db.collection('canchas').add({
      'sedeId': sedesIds['jugada'],
      'image': 'lib/images/jsintecho.jpg',
      'title': 'Cancha Abierta',
      'price': '\$60.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'abierta',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Abierta');
    totalCanchas++;

    // Canchas La Jugada Secundaria
    print('  📍 La Jugada Secundaria:');
    await _db.collection('canchas').add({
      'sedeId': sedesIds['jugada2'],
      'image': 'lib/images/sintecho.jpg',
      'title': 'Cancha Abierta #1',
      'price': '\$70.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'abierta',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Abierta #1');
    totalCanchas++;

    await _db.collection('canchas').add({
      'sedeId': sedesIds['jugada2'],
      'image': 'lib/images/j2.jpg',
      'title': 'Cancha Abierta #2',
      'price': '\$70.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'abierta',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Abierta #2');
    totalCanchas++;

    await _db.collection('canchas').add({
      'sedeId': sedesIds['jugada2'],
      'image': 'lib/images/j3.jpg',
      'title': 'Cancha Abierta #3',
      'price': '\$70.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'abierta',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Abierta #3');
    totalCanchas++;

    // Canchas Biblos
    print('  📍 Biblos:');
    await _db.collection('canchas').add({
      'sedeId': sedesIds['biblos'],
      'image': 'lib/images/1.jpg',
      'title': 'Cancha Techada Biblos #1',
      'price': '\$80.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'cerrada',
      'jugadores': '6 vs 6',
    });
    print('    ✓ Cancha Techada #1');
    totalCanchas++;

    await _db.collection('canchas').add({
      'sedeId': sedesIds['biblos'],
      'image': 'lib/images/3.jpg',
      'title': 'Cancha Techada Biblos #2',
      'price': '\$80.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'cerrada',
      'jugadores': '6 vs 6',
    });
    print('    ✓ Cancha Techada #2');
    totalCanchas++;

    await _db.collection('canchas').add({
      'sedeId': sedesIds['biblos'],
      'image': 'lib/images/6.jpg',
      'title': 'Cancha Abierta Biblos #1',
      'price': '\$50.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'abierta',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Abierta #1');
    totalCanchas++;

    await _db.collection('canchas').add({
      'sedeId': sedesIds['biblos'],
      'image': 'lib/images/7.jpg',
      'title': 'Cancha Abierta Biblos #2',
      'price': '\$50.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'abierta',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Abierta #2');
    totalCanchas++;

    // Canchas El Fortín
    print('  📍 El Fortín:');
    await _db.collection('canchas').add({
      'sedeId': sedesIds['fortin'],
      'image': 'lib/images/fsintecho2.jpg',
      'title': 'Cancha Abierta',
      'price': '\$70.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'sintetica',
      'jugadores': '6 vs 6',
    });
    print('    ✓ Cancha Abierta');
    totalCanchas++;

    await _db.collection('canchas').add({
      'sedeId': sedesIds['fortin'],
      'image': 'lib/images/ftecho.jpg',
      'title': 'Cancha Techada',
      'price': '\$60.000 COP',
      'horario': '7:00 AM - 11:00 PM',
      'tipo': 'natural',
      'jugadores': '5 vs 5',
    });
    print('    ✓ Cancha Techada');
    totalCanchas++;

    print('✅ $totalCanchas canchas creadas');
  }

  /// Método para limpiar toda la base de datos (usar con cuidado)
  static Future<void> limpiarBaseDatos() async {
    print('⚠️  ADVERTENCIA: Limpiando toda la base de datos...');
    
    int totalEliminados = 0;

    // Eliminar todas las reservas
    print('🗑️  Eliminando reservas...');
    final reservas = await _db.collection('reservas').get();
    for (var doc in reservas.docs) {
      await doc.reference.delete();
      totalEliminados++;
    }
    print('  ✓ ${reservas.docs.length} reservas eliminadas');

    // Eliminar todas las canchas
    print('🗑️  Eliminando canchas...');
    final canchas = await _db.collection('canchas').get();
    for (var doc in canchas.docs) {
      await doc.reference.delete();
      totalEliminados++;
    }
    print('  ✓ ${canchas.docs.length} canchas eliminadas');

    // Eliminar todas las sedes
    print('🗑️  Eliminando sedes...');
    final sedes = await _db.collection('sedes').get();
    for (var doc in sedes.docs) {
      await doc.reference.delete();
      totalEliminados++;
    }
    print('  ✓ ${sedes.docs.length} sedes eliminadas');

    print('✅ Base de datos limpiada completamente');
    print('📊 Total documentos eliminados: $totalEliminados');
  }

  /// Crear reservas de ejemplo para testing
  static Future<void> crearReservasEjemplo() async {
    print('📅 Creando reservas de ejemplo...');

    // Obtener una cancha para las reservas
    final canchasSnapshot = await _db.collection('canchas').limit(1).get();
    if (canchasSnapshot.docs.isEmpty) {
      print('❌ No hay canchas disponibles. Primero pobla los datos iniciales.');
      return;
    }

    final cancha = canchasSnapshot.docs.first;
    final canchaData = cancha.data();
    final canchaId = cancha.id;
    final sedeId = canchaData['sedeId'];

    // Crear 3 reservas de ejemplo
    final reservas = [
      {
        'nombreCompleto': 'Adel Andrés Orellano',
        'correoElectronico': 'andresorellano591@gmail.com',
        'numeroCelular': '3003525431',
        'fechaReserva': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'horaReserva': '17:00 - 18:00',
        'tipoCancha': 'TipoCancha.cerrada',
        'canchaId': canchaId,
        'sedeId': sedeId,
        'estado': 'pendiente',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'nombreCompleto': 'Carlos Ruiz',
        'correoElectronico': 'carlos.ruiz@mail.com',
        'numeroCelular': '3002223344',
        'fechaReserva': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'horaReserva': '14:00 - 15:00',
        'tipoCancha': 'TipoCancha.abierta',
        'canchaId': canchaId,
        'sedeId': sedeId,
        'estado': 'pagado',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'nombreCompleto': 'Sofía Ramírez',
        'correoElectronico': 'sofia.ramirez@mail.com',
        'numeroCelular': '3003334455',
        'fechaReserva': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'horaReserva': '18:00 - 19:00',
        'tipoCancha': 'TipoCancha.cerrada',
        'canchaId': canchaId,
        'sedeId': sedeId,
        'estado': 'pendiente',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var reserva in reservas) {
      await _db.collection('reservas').add(reserva);
      print('  ✓ Reserva creada: ${reserva['nombreCompleto']}');
    }

    print('✅ ${reservas.length} reservas de ejemplo creadas');
  }

  /// Obtener estadísticas de la base de datos
  static Future<void> mostrarEstadisticas() async {
    print('📊 Estadísticas de la base de datos:');
    print('════════════════════════════════════');

    final sedes = await _db.collection('sedes').get();
    print('📍 Sedes: ${sedes.docs.length}');

    final canchas = await _db.collection('canchas').get();
    print('⚽ Canchas: ${canchas.docs.length}');

    final reservas = await _db.collection('reservas').get();
    print('📅 Reservas: ${reservas.docs.length}');

    if (reservas.docs.isNotEmpty) {
      int pendientes = 0;
      int pagadas = 0;
      int canceladas = 0;

      for (var doc in reservas.docs) {
        final estado = doc.data()['estado'] ?? 'pendiente';
        if (estado == 'pendiente') pendientes++;
        if (estado == 'pagado') pagadas++;
        if (estado == 'cancelado') canceladas++;
      }

      print('  ├─ Pendientes: $pendientes');
      print('  ├─ Pagadas: $pagadas');
      print('  └─ Canceladas: $canceladas');
    }

    print('════════════════════════════════════');
  }
}