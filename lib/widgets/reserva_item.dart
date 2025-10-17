// lib/widgets/reserva_item.dart
import 'package:flutter/material.dart';
import '../utils/reserva_estado.dart';

class ReservaItem extends StatelessWidget {
  final Map<String, dynamic> reserva;
  final VoidCallback onTap;

  const ReservaItem({
    super.key,
    required this.reserva,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = reserva['nombreCompleto'] ?? 'Sin nombre';
    final inicial = (nombre.isNotEmpty ? nombre.trim()[0] : '?').toUpperCase();
    final estado = ReservaEstadoHelper.desdeString(reserva['estado'] ?? 'pendiente');
    final sede = reserva['sede'] != null 
        ? reserva['sede']['title'] ?? 'Sin sede' 
        : 'Sin sede';
    final hora = reserva['horaReserva'] ?? 'Sin hora';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0.8,
        color: const Color(0xFFF0F3F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0083B0),
                child: Text(
                  inicial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: estado.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: estado.color.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            estado.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: estado.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$sede • $hora',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}