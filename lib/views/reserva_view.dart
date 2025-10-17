// lib/views/reserva_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/reserva_controller.dart';
import '../routes/app_routes.dart';

class ReservaView extends StatelessWidget {
  const ReservaView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReservaController>(context);

    const String nombreFijo = "Andres Orellano";
    const String correoFijo = "andresorellano591@gmail.com";
    const String celularFijo = "3003525431";

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
              // Nombre completo (ya lleno)
              TextFormField(
                controller: controller.nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Correo electrónico (ya lleno)
              TextFormField(
                controller: controller.correoController,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Número de celular (ya lleno)
              TextFormField(
                controller: controller.celularController,
                decoration: const InputDecoration(
                  labelText: "Número de celular",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Fecha de reserva
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  controller.fechaReserva == null
                      ? "Seleccione una fecha"
                      : "Fecha: ${controller.fechaReserva!.day}/${controller.fechaReserva!.month}/${controller.fechaReserva!.year}",
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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

              // Selección de hora
              DropdownButtonFormField<String>(
                value: controller.horaSeleccionada,
                decoration: const InputDecoration(
                  labelText: "Hora de reserva",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
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

              // Política de cambios
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Si desea cambiar la fecha, debe hacerlo con al menos 1 hora de anticipación para conservar el abono.",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón de confirmar
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (controller.formKey.currentState!.validate()) {
                      // Mostrar loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      final resultado = await controller.confirmarReserva();
                      
                      // Cerrar loading
                      if (context.mounted) Navigator.pop(context);

                      if (resultado['success']) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(resultado['message']),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          
                          // Navegar a pagos
                          Navigator.pushNamed(context, AppRoutes.pagos);
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(resultado['message']),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    "Confirmar reserva",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}