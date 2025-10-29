// lib/widgets/reserva_detalle_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/reserva_estado.dart';

class ReservaDetalleSheet extends StatelessWidget {
  final Map<String, dynamic> reserva;
  final VoidCallback onEstadoActualizado;

  const ReservaDetalleSheet({
    super.key,
    required this.reserva,
    required this.onEstadoActualizado,
  });

  Future<void> _actualizarEstado(
    BuildContext context,
    String nuevoEstado,
    String mensaje,
  ) async {
    final reservaId = reserva['id'];
    if (reservaId == null) return;

    try {
      await FirestoreService().actualizarEstadoReserva(reservaId, nuevoEstado);
      onEstadoActualizado();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _rowIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0083B0)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ReservaEstadoHelper.desdeString(
      reserva['estado'] ?? 'pendiente',
    );
    final sede = reserva['sede'] != null
        ? reserva['sede']['title'] ?? 'Sin sede'
        : 'Sin sede';
    final cancha = reserva['cancha'] != null
        ? reserva['cancha']['title'] ?? 'Sin cancha'
        : 'Sin cancha';
    final precio = reserva['cancha'] != null
        ? reserva['cancha']['price'] ?? '\$0'
        : '\$0';

    String fechaTexto = 'Sin fecha';
    final dynamic fechaReservaRaw = reserva['fechaReserva'];

    if (fechaReservaRaw != null) {
      DateTime fecha;
      if (fechaReservaRaw is Timestamp) {
        fecha = fechaReservaRaw.toDate();
      } else if (fechaReservaRaw is DateTime) {
        fecha = fechaReservaRaw;
      } else if (fechaReservaRaw is String) {
        fecha = DateTime.tryParse(fechaReservaRaw) ?? DateTime.now();
      } else {
        fecha = DateTime.now();
      }
      fechaTexto = DateFormat('dd/MM/yyyy').format(fecha);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Detalles de la Reserva',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _rowIconText(
            Icons.person_pin_circle_outlined,
            'Nombre: ${reserva['nombreCompleto'] ?? 'Sin nombre'}',
          ),
          _rowIconText(
            Icons.alternate_email,
            'Correo: ${reserva['correoElectronico'] ?? 'Sin correo'}',
          ),
          _rowIconText(
            Icons.phone_android,
            'Teléfono: ${reserva['numeroCelular'] ?? 'Sin teléfono'}',
          ),
          _rowIconText(Icons.place_outlined, 'Sede: $sede'),
          _rowIconText(
            Icons.calendar_today_outlined,
            'Fecha: $fechaTexto',
          ),
          _rowIconText(
            Icons.access_time_filled_outlined,
            'Hora: ${reserva['horaReserva'] ?? 'Sin hora'}',
          ),
          _rowIconText(Icons.sports_soccer_outlined, 'Cancha: $cancha'),
          _rowIconText(Icons.attach_money, 'Monto: $precio'),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                const TextSpan(
                  text: 'Estado actual: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: estado.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: estado.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Marcar Pagado'),
                  onPressed: () => _actualizarEstado(
                    context,
                    'pagado',
                    'Reserva marcada como PAGADO',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancelar'),
                  onPressed: () => _actualizarEstado(
                    context,
                    'cancelado',
                    'Reserva CANCELADA',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}
