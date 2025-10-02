// models/reserva_model.dart

import 'cancha_model.dart';

class ReservaModel {
  final String nombreCompleto;
  final String correoElectronico;
  final String numeroCelular;
  final DateTime? fechaReserva;
  final String? horaReserva;
  final TipoCancha tipoCancha;

  ReservaModel({
    required this.nombreCompleto,
    required this.correoElectronico,
    required this.numeroCelular,
    this.fechaReserva,
    this.horaReserva,
    required this.tipoCancha,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      nombreCompleto: json['nombreCompleto'] ?? '',
      correoElectronico: json['correoElectronico'] ?? '',
      numeroCelular: json['numeroCelular'] ?? '',
      fechaReserva: json['fechaReserva'] != null 
          ? DateTime.parse(json['fechaReserva']) 
          : null,
      horaReserva: json['horaReserva'],
      tipoCancha: json['tipoCancha'] == 'TipoCancha.cerrada' 
          ? TipoCancha.cerrada 
          : TipoCancha.abierta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreCompleto': nombreCompleto,
      'correoElectronico': correoElectronico,
      'numeroCelular': numeroCelular,
      'fechaReserva': fechaReserva?.toIso8601String(),
      'horaReserva': horaReserva,
      'tipoCancha': tipoCancha.toString(),
    };
  }

  bool get isValid {
    return nombreCompleto.isNotEmpty &&
        correoElectronico.isNotEmpty &&
        numeroCelular.isNotEmpty &&
        fechaReserva != null &&
        horaReserva != null;
  }
}