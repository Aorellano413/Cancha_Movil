// controllers/reserva_controller.dart

import 'package:flutter/material.dart';
import '../models/reserva_model.dart';
import '../models/cancha_model.dart';

class ReservaController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  
  DateTime? _fechaReserva;
  String? _horaSeleccionada;
  TipoCancha? _tipoCanchaSeleccionada;

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

  ReservaModel? crearReserva() {
    if (_tipoCanchaSeleccionada == null) return null;

    final reserva = ReservaModel(
      nombreCompleto: nombreController.text,
      correoElectronico: correoController.text,
      numeroCelular: celularController.text,
      fechaReserva: _fechaReserva,
      horaReserva: _horaSeleccionada,
      tipoCancha: _tipoCanchaSeleccionada!,
    );

    if (reserva.isValid) {
      return reserva;
    }
    return null;
  }

  Future<bool> confirmarReserva() async {
    final reserva = crearReserva();
    if (reserva == null) return false;

    // Aquí puedes agregar lógica para guardar en base de datos
    // o enviar a un API
    print('Reserva confirmada: ${reserva.toJson()}');
    
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));
    
    return true;
  }

  void limpiarFormulario() {
    nombreController.clear();
    correoController.clear();
    celularController.clear();
    _fechaReserva = null;
    _horaSeleccionada = null;
    _tipoCanchaSeleccionada = null;
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