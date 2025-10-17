// ============= lib/models/reserva_model.dart =============
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cancha_model.dart';

class ReservaModel {
  final String? id; // ID de Firestore
  final String nombreCompleto;
  final String correoElectronico;
  final String numeroCelular;
  final DateTime? fechaReserva;
  final String? horaReserva;
  final TipoCancha tipoCancha;
  final String? canchaId;
  final String? sedeId;
  final String? estado; // pendiente, confirmada, cancelada, pagado

  ReservaModel({
    this.id,
    required this.nombreCompleto,
    required this.correoElectronico,
    required this.numeroCelular,
    this.fechaReserva,
    this.horaReserva,
    required this.tipoCancha,
    this.canchaId,
    this.sedeId,
    this.estado = 'pendiente',
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    DateTime? fecha;
    if (json['fechaReserva'] != null) {
      if (json['fechaReserva'] is Timestamp) {
        fecha = (json['fechaReserva'] as Timestamp).toDate();
      } else if (json['fechaReserva'] is String) {
        fecha = DateTime.parse(json['fechaReserva']);
      }
    }

    return ReservaModel(
      id: json['id'],
      nombreCompleto: json['nombreCompleto'] ?? '',
      correoElectronico: json['correoElectronico'] ?? '',
      numeroCelular: json['numeroCelular'] ?? '',
      fechaReserva: fecha,
      horaReserva: json['horaReserva'],
      tipoCancha: _parseTipoCancha(json['tipoCancha']),
      canchaId: json['canchaId'],
      sedeId: json['sedeId'],
      estado: json['estado'] ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombreCompleto': nombreCompleto,
      'correoElectronico': correoElectronico,
      'numeroCelular': numeroCelular,
      if (fechaReserva != null) 'fechaReserva': Timestamp.fromDate(fechaReserva!),
      'horaReserva': horaReserva,
      'tipoCancha': tipoCancha.toString(),
      if (canchaId != null) 'canchaId': canchaId,
      if (sedeId != null) 'sedeId': sedeId,
      'estado': estado,
    };
  }

  static TipoCancha _parseTipoCancha(String? tipoStr) {
    if (tipoStr == null) return TipoCancha.abierta;
    
    if (tipoStr.contains('cerrada')) return TipoCancha.cerrada;
    if (tipoStr.contains('natural')) return TipoCancha.natural;
    if (tipoStr.contains('techada')) return TipoCancha.techada;
    if (tipoStr.contains('sintetica')) return TipoCancha.sintetica;
    
    return TipoCancha.abierta;
  }

  bool get isValid {
    return nombreCompleto.isNotEmpty &&
        correoElectronico.isNotEmpty &&
        numeroCelular.isNotEmpty &&
        fechaReserva != null &&
        horaReserva != null;
  }

  ReservaModel copyWith({
    String? id,
    String? nombreCompleto,
    String? correoElectronico,
    String? numeroCelular,
    DateTime? fechaReserva,
    String? horaReserva,
    TipoCancha? tipoCancha,
    String? canchaId,
    String? sedeId,
    String? estado,
  }) {
    return ReservaModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correoElectronico: correoElectronico ?? this.correoElectronico,
      numeroCelular: numeroCelular ?? this.numeroCelular,
      fechaReserva: fechaReserva ?? this.fechaReserva,
      horaReserva: horaReserva ?? this.horaReserva,
      tipoCancha: tipoCancha ?? this.tipoCancha,
      canchaId: canchaId ?? this.canchaId,
      sedeId: sedeId ?? this.sedeId,
      estado: estado ?? this.estado,
    );
  }
}