import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/reserva_controller.dart';

class ReservaView extends StatelessWidget {
  const ReservaView({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí usamos un Consumer con ChangeNotifierProvider
    // para asegurarnos de que siempre haya un ReservaController disponible
    return ChangeNotifierProvider(
      create: (_) => ReservaController(),
      child: Consumer<ReservaController>(
        builder: (context, controller, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Reserva de cancha"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context), // Regresa a InicioView
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: controller.formKey,
                child: ListView(
                  children: [
                    // Nombre
                    TextFormField(
                      controller: controller.nombreController,
                      decoration: const InputDecoration(
                        labelText: "Nombre completo",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Correo
                    TextFormField(
                      controller: controller.correoController,
                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su correo';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor ingrese un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Celular
                    TextFormField(
                      controller: controller.celularController,
                      decoration: const InputDecoration(
                        labelText: "Número de celular",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su número de celular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Fecha
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
                    // Hora
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
                    // Política
                    const Text(
                      "Política: Si desea cambiar la fecha, debe hacerlo con al menos 1 hora de anticipación para conservar el abono.",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Botón confirmar
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
                            Navigator.pop(context); 
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
        },
      ),
    );
  }
}
