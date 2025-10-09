// views/reserva_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/reserva_controller.dart';
import '../routes/app_routes.dart';

class ReservaView extends StatelessWidget {
  const ReservaView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReservaController>(context);

    // ✅ Datos estáticos del usuario
    const String nombreFijo = "Andres Orellano";
    const String correoFijo = "andresorellano591@gmail.com";
    const String celularFijo = "3003525431";

    // ✅ Precargamos los datos en los controladores (solo una vez)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.nombreController.text.isEmpty) {
        controller.nombreController.text = nombreFijo;
        controller.correoController.text = correoFijo;
        controller.celularController.text = celularFijo;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reserva de cancha"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              // 🔹 Campo nombre (ya lleno)
              TextFormField(
                controller: controller.nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // No editable
              ),
              const SizedBox(height: 16),

              // 🔹 Campo correo (ya lleno)
              TextFormField(
                controller: controller.correoController,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // No editable
              ),
              const SizedBox(height: 16),

              // 🔹 Campo celular (ya lleno)
              TextFormField(
                controller: controller.celularController,
                decoration: const InputDecoration(
                  labelText: "Número de celular",
                  border: OutlineInputBorder(),
                ),
                readOnly: true, // No editable
              ),
              const SizedBox(height: 16),

              // 🔹 Fecha de reserva
              ListTile(
                title: Text(
                  controller.fechaReserva == null
                      ? "Seleccione una fecha"
                      : "Fecha: ${controller.fechaReserva!.day}/${controller.fechaReserva!.month}/${controller.fechaReserva!.year}",
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
                    controller.setFechaReserva(fecha);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 🔹 Selección de hora
              DropdownButtonFormField<String>(
                value: controller.horaSeleccionada,
                decoration: const InputDecoration(
                  labelText: "Hora de reserva",
                  border: OutlineInputBorder(),
                ),
                items: controller.horas.map((hora) {
                  return DropdownMenuItem(
                    value: hora,
                    child: Text(hora),
                  );
                }).toList(),
                onChanged: (value) => controller.setHoraSeleccionada(value),
                validator: (value) {
                  if (value == null) return 'Por favor seleccione una hora';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                "Política: Si desea cambiar la fecha, debe hacerlo con al menos 1 hora de anticipación para conservar el abono.",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Botón de confirmar
              ElevatedButton(
                onPressed: () async {
                  if (controller.formKey.currentState!.validate()) {
                    final confirmado = await controller.confirmarReserva();
                    if (confirmado && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reserva confirmada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      controller.limpiarFormulario();

                      // Ir a vista de pagos
                      Navigator.pushNamed(context, AppRoutes.pagos);
                    }
                  }
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
