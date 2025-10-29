// lib/controllers/reserva_controller.dart
import 'package:flutter/material.dart';
import '../models/reserva_model.dart';
import '../models/cancha_model.dart';
import '../services/firestore_service.dart';

class ReservaController extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final formKey = GlobalKey<FormState>();
  
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  
  DateTime? _fechaReserva;
  String? _horaSeleccionada;
  TipoCancha? _tipoCanchaSeleccionada;
  String? _canchaIdSeleccionada;
  String? _sedeIdSeleccionada;

  final List<String> horas = List.generate(
    14,
    (index) {
      final horaInicio = 8 + index;
      final horaFin = horaInicio + 1;
      return "${horaInicio.toString().padLeft(2, '0')}:00 - ${horaFin.toString().padLeft(2, '0')}:00";
    },
  );

  DateTime? get fechaReserva => _fechaReserva;
  String? get horaSeleccionada => _horaSeleccionada;
  TipoCancha? get tipoCanchaSeleccionada => _tipoCanchaSeleccionada;
  String? get canchaIdSeleccionada => _canchaIdSeleccionada;
  String? get sedeIdSeleccionada => _sedeIdSeleccionada;

  void setFechaReserva(DateTime? fecha) {
    _fechaReserva = fecha;
    notifyListeners();
  }

  void setHoraSeleccionada(String? hora) {
    _horaSeleccionada = hora;
    notifyListeners();
  }

  void setTipoCancha(TipoCancha tipo) {
    _tipoCanchaSeleccionada = tipo;
    notifyListeners();
  }

  void setCanchaId(String? canchaId) {
    _canchaIdSeleccionada = canchaId;
    notifyListeners();
  }

  void setSedeId(String? sedeId) {
    _sedeIdSeleccionada = sedeId;
    notifyListeners();
  }

  ReservaModel? crearReserva() {
    if (_tipoCanchaSeleccionada == null) return null;

    final reserva = ReservaModel(
      nombreCompleto: nombreController.text,
      correoElectronico: correoController.text,
      numeroCelular: celularController.text,
      fechaReserva: _fechaReserva,
      horaReserva: _horaSeleccionada,
      tipoCancha: _tipoCanchaSeleccionada!,
      canchaId: _canchaIdSeleccionada,
      sedeId: _sedeIdSeleccionada,
    );

    if (reserva.isValid) {
      return reserva;
    }
    return null;
  }

  Future<Map<String, dynamic>> confirmarReserva() async {
    final reserva = crearReserva();
    if (reserva == null) {
      return {
        'success': false,
        'message': 'Datos de reserva incompletos',
      };
    }

    if (_canchaIdSeleccionada == null || _sedeIdSeleccionada == null) {
      return {
        'success': false,
        'message': 'Debe seleccionar una cancha específica',
      };
    }

    try {
      final disponible = await _firestore.verificarDisponibilidad(
        canchaId: _canchaIdSeleccionada!,
        fecha: _fechaReserva!,
        horaReserva: _horaSeleccionada!,
      );

      if (!disponible) {
        return {
          'success': false,
          'message': 'Esta cancha ya está reservada para esa fecha y hora',
        };
      }

      
      final reservaId = await _firestore.crearReserva(
        reserva,
        _canchaIdSeleccionada!,
        _sedeIdSeleccionada!,
      );

      print('Reserva confirmada con ID: $reservaId');

      return {
        'success': true,
        'message': 'Reserva creada exitosamente',
        'reservaId': reservaId,
      };
    } catch (e) {
      print('Error al confirmar reserva: $e');
      return {
        'success': false,
        'message': 'Error al crear la reserva: $e',
      };
    }
  }

  void limpiarCamposFormulario() {
    nombreController.clear();
    correoController.clear();
    celularController.clear();
    _fechaReserva = null;
    _horaSeleccionada = null;
    notifyListeners();
  }

  void limpiarFormulario() {
    nombreController.clear();
    correoController.clear();
    celularController.clear();
    _fechaReserva = null;
    _horaSeleccionada = null;
    _tipoCanchaSeleccionada = null;
    _canchaIdSeleccionada = null;
    _sedeIdSeleccionada = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    celularController.dispose();
    super.dispose();
  }
}