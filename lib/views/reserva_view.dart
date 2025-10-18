// lib/views/reserva_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/reserva_controller.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';

class ReservaView extends StatelessWidget {
  const ReservaView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReservaController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reserva de cancha"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpiar campos',
            onPressed: () {
              controller.limpiarCamposFormulario();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Campos limpiados (se mantiene la cancha seleccionada)'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              // ✅ Nombre completo - AHORA EDITABLE
              TextFormField(
                controller: controller.nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Ej: Juan Pérez',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese su nombre completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ✅ Correo electrónico - AHORA EDITABLE
              TextFormField(
                controller: controller.correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Correo electrónico",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Ej: correo@ejemplo.com',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese su correo';
                  }
                  // Validación básica de email
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor ingrese un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ✅ Número de celular - AHORA EDITABLE
              TextFormField(
                controller: controller.celularController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Número de celular",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Ej: 3001234567',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingrese su número de celular';
                  }
                  // Validación básica para Colombia (10 dígitos)
                  if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
                    return 'Ingrese un número válido (mínimo 10 dígitos)';
                  }
                  return null;
                },
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
                      // Validar que se haya seleccionado fecha
                      if (controller.fechaReserva == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor seleccione una fecha'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

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
                        // ✅ OBTENER DATOS DIRECTAMENTE DE FIRESTORE
                        try {
                          final firestore = FirestoreService();
                          
                          // Obtener datos de la cancha
                          String canchaNombre = 'Sin cancha';
                          String precio = '0';
                          
                          if (controller.canchaIdSeleccionada != null) {
                            final canchaDoc = await firestore
                                .getCanchasPorSede(controller.sedeIdSeleccionada ?? '');
                            
                            final cancha = canchaDoc.firstWhere(
                              (c) => c.id == controller.canchaIdSeleccionada,
                              orElse: () => canchaDoc.first,
                            );
                            
                            canchaNombre = cancha.title;
                            precio = cancha.price.replaceAll(RegExp(r'[^0-9]'), '');
                          }
                          
                          // Obtener datos de la sede
                          String sedeNombre = 'Sin sede';
                          
                          if (controller.sedeIdSeleccionada != null) {
                            final sedes = await firestore.getSedes();
                            final sede = sedes.firstWhere(
                              (s) => s.id == controller.sedeIdSeleccionada,
                              orElse: () => sedes.first,
                            );
                            sedeNombre = sede.title;
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resultado['message']),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            
                            // Guardar datos antes de navegar
                            final datosReserva = {
                              'nombreCompleto': controller.nombreController.text.trim(),
                              'correoElectronico': controller.correoController.text.trim(),
                              'numeroCelular': controller.celularController.text.trim(),
                              'fechaReserva': controller.fechaReserva,
                              'horaReserva': controller.horaSeleccionada,
                              'sedeNombre': sedeNombre,
                              'canchaNombre': canchaNombre,
                              'precio': precio,
                            };
                            
                            // ✅ NAVEGAR A PAGOS CON LOS DATOS REALES
                            // NO limpiamos aquí porque perdemos los IDs de sede y cancha
                            Navigator.pushNamed(
                              context,
                              AppRoutes.pagos,
                              arguments: datosReserva,
                            ).then((_) {
                              // ✅ LIMPIAR SOLO LOS CAMPOS DEL FORMULARIO
                              // Mantenemos los IDs de sede y cancha para facilitar múltiples reservas
                              controller.limpiarCamposFormulario();
                            });
                          }
                        } catch (e) {
                          print('Error al obtener datos: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reserva creada pero error al cargar detalles: $e'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
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