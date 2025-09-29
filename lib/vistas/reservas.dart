import 'package:flutter/material.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  DateTime? _fechaReserva;
  String? _horaSeleccionada;

  final List<String> _horas = List.generate(
    14,
    (index) {
      final horaInicio = 8 + index;
      final horaFin = horaInicio + 1;
      return "${horaInicio.toString().padLeft(2, '0')}:00 - ${horaFin.toString().padLeft(2, '0')}:00";
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reserva de cancha"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre completo
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Correo electrónico
              TextFormField(
                controller: _correoController,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Número de celular
              TextFormField(
                controller: _celularController,
                decoration: const InputDecoration(
                  labelText: "Número de celular",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Fecha de reserva
              ListTile(
                title: Text(
                  _fechaReserva == null
                      ? "Seleccione una fecha"
                      : "Fecha: ${_fechaReserva!.day}/${_fechaReserva!.month}/${_fechaReserva!.year}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (fecha != null) {
                    setState(() {
                      _fechaReserva = fecha;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Hora de reserva
              DropdownButtonFormField<String>(
                value: _horaSeleccionada,
                decoration: const InputDecoration(
                  labelText: "Hora de reserva",
                  border: OutlineInputBorder(),
                ),
                items: _horas.map((hora) {
                  return DropdownMenuItem(
                    value: hora,
                    child: Text(hora),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _horaSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Política
              const Text(
                "Política: Si desea cambiar la fecha, debe hacerlo con al menos 1 hora de anticipación para conservar el abono.",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),

              // Botón confirmar (no funcional)
              ElevatedButton(
                onPressed: () {
                  // No hace nada, solo es UI
                },
                child: const Text("Confirmar reserva"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
