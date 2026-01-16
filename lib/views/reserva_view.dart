// lib/views/reserva_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/reserva_controller.dart';
import '../services/firestore_service.dart';
import '../routes/app_routes.dart';
import '../services/email_service.dart';

class ReservaView extends StatefulWidget {
  const ReservaView({super.key});

  @override
  State<ReservaView> createState() => _ReservaViewState();
}

class _ReservaViewState extends State<ReservaView> {
  bool _processing = false;

  Future<void> _mostrarProcesando(BuildContext context, {String mensaje = 'Procesando reserva…'}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 64),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Un momento…', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(mensaje, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ReservaController>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset("lib/images/fondo.jpg", fit: BoxFit.cover),
          ),

          // Blur del fondo
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          // Contenido
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // AppBar personalizado
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reserva de Cancha',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          tooltip: 'Limpiar campos',
                          onPressed: () {
                            controller.limpiarCamposFormulario();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Campos limpiados ',
                                  style: GoogleFonts.poppins(),
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: controller.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Nombre completo
                                TextFormField(
                                  controller: controller.nombreController,
                                  maxLength: 20,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: "Nombre completo",
                                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                                    hintText: 'Ej: Juan Pérez',
                                    hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.15),
                                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                    ),
                                    errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúñÑ ]')),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Por favor ingrese su nombre completo';
                                    }
                                    final trimmed = value.trim();
                                    if (trimmed.length < 2 || trimmed.length > 20) {
                                      return 'El nombre debe tener entre 2 y 20 caracteres';
                                    }
                                    final regex = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúñÑ ]+$');
                                    if (!regex.hasMatch(trimmed)) {
                                      return 'El nombre solo puede contener letras y espacios';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: controller.correoController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: "Correo electrónico",
                                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                                    hintText: 'Ej: correo@ejemplo.com',
                                    hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.15),
                                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                    ),
                                    errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Por favor ingrese su correo';
                                    }
                                    final trimmed = value.trim();
                                    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegex.hasMatch(trimmed)) {
                                      return 'Por favor ingrese un correo válido';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: controller.celularController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    labelText: "Número de celular",
                                    labelStyle: GoogleFonts.poppins(color: Colors.white70),
                                    hintText: 'Ej: 3001234567',
                                    hintStyle: GoogleFonts.poppins(color: Colors.white54),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.15),
                                    prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                    ),
                                    errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
                                  ),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Por favor ingrese su número de celular';
                                    }
                                    final cleaned = value.replaceAll(RegExp(r'\D'), '');
                                    if (cleaned.length != 10) {
                                      return 'El celular debe tener exactamente 10 dígitos';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                InkWell(
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
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: Colors.white70),
                                        const SizedBox(width: 12),
                                        Text(
                                          controller.fechaReserva == null
                                              ? "Seleccione una fecha"
                                              : "Fecha: ${controller.fechaReserva!.day}/${controller.fechaReserva!.month}/${controller.fechaReserva!.year}",
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                FutureBuilder<List<Map<String, dynamic>>>(
                                  future: _obtenerHorasConEstado(controller),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              "Cargando horarios...",
                                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    final horasConEstado = snapshot.data ?? [];

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          value: controller.horaSeleccionada,
                                          dropdownColor: const Color(0xFF1A1A2E),
                                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                          decoration: InputDecoration(
                                            labelText: "Hora de reserva",
                                            labelStyle: GoogleFonts.poppins(color: Colors.white70),
                                            filled: true,
                                            fillColor: Colors.white.withOpacity(0.15),
                                            prefixIcon: const Icon(Icons.access_time, color: Colors.white70),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                                            ),
                                            errorStyle: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12),
                                          ),
                                          items: horasConEstado.map((horaData) {
                                            final hora = horaData['hora'] as String;
                                            final ocupada = horaData['ocupada'] as bool;

                                            return DropdownMenuItem<String>(
                                              value: hora,
                                              enabled: !ocupada,
                                              child: Text(
                                                hora,
                                                style: GoogleFonts.poppins(
                                                  color: ocupada ? Colors.red : Colors.white,
                                                  fontWeight: ocupada ? FontWeight.bold : FontWeight.normal,
                                                  decoration: ocupada ? TextDecoration.lineThrough : null,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            controller.setHoraSeleccionada(value);
                                          },
                                          validator: (value) {
                                            if (value == null) return 'Por favor seleccione una hora';
                                            final sel = horasConEstado.firstWhere(
                                              (h) => h['hora'] == value,
                                              orElse: () => {'ocupada': false},
                                            );
                                            if (sel['ocupada'] == true) {
                                              return 'La hora seleccionada ya está reservada';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Aviso importante
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withOpacity(0.4), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.red.shade200),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Si desea cambiar la fecha, debe hacerlo con al menos 1 hora de anticipación para conservar el abono.",
                                          style: GoogleFonts.poppins(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.red.shade200,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                SizedBox(
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _processing
                                        ? null
                                        : () async {
                                            FocusScope.of(context).unfocus();

                                            if (!controller.formKey.currentState!.validate()) return;

                                            if (controller.fechaReserva == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Por favor seleccione una fecha', style: GoogleFonts.poppins()),
                                                  backgroundColor: Colors.orange,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() => _processing = true);
                                            _mostrarProcesando(context, mensaje: 'Validando disponibilidad...');

                                            final resultado = await controller.confirmarReserva();

                                            if (mounted) {
                                              Navigator.of(context, rootNavigator: true).pop();
                                            }

                                            if (!resultado['success']) {
                                              if (mounted) {
                                                setState(() => _processing = false);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(resultado['message'], style: GoogleFonts.poppins()),
                                                    backgroundColor: Colors.red,
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                              return;
                                            }

                                            try {
                                              final firestore = FirestoreService();

                                              String canchaNombre = 'Sin cancha';
                                              String precio = '0';
                                              if (controller.canchaIdSeleccionada != null) {
                                                final canchas = await firestore.getCanchasPorSede(controller.sedeIdSeleccionada ?? '');
                                                final cancha = canchas.firstWhere(
                                                  (c) => c.id == controller.canchaIdSeleccionada,
                                                  orElse: () => canchas.first,
                                                );
                                                canchaNombre = cancha.title;
                                                precio = cancha.price.replaceAll(RegExp(r'[^0-9]'), '');
                                              }

                                              String sedeNombre = 'Sin sede';
                                              if (controller.sedeIdSeleccionada != null) {
                                                final sedes = await firestore.getSedes();
                                                final sede = sedes.firstWhere(
                                                  (s) => s.id == controller.sedeIdSeleccionada,
                                                  orElse: () => sedes.first,
                                                );
                                                sedeNombre = sede.title;
                                              }

                                              () async {
                                                try {
                                                  final emailService = EmailService(
                                                    smtpUser: 'reservasports5@gmail.com',
                                                    appPassword: 'zlxnskpuwfutbtzq',
                                                    host: 'smtp.gmail.com',
                                                    port: 587,
                                                  );

                                                  await emailService.enviarCorreosReserva(
                                                    correoUsuario: controller.correoController.text.trim(),
                                                    nombreUsuario: controller.nombreController.text.trim(),
                                                    fechaReserva: controller.fechaReserva!,
                                                    horaReserva: controller.horaSeleccionada!,
                                                    sedeNombre: sedeNombre,
                                                    canchaNombre: canchaNombre,
                                                    precio: precio,
                                                    correoAdmin: 'reservasports5@gmail.com',
                                                  );
                                                } catch (_) {}
                                              }();

                                              if (!mounted) return;

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(resultado['message'], style: GoogleFonts.poppins()),
                                                  backgroundColor: Colors.green,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );

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

                                              setState(() => _processing = false);

                                              if (mounted) {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.pagos,
                                                  arguments: datosReserva,
                                                ).then((_) => controller.limpiarCamposFormulario());
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                setState(() => _processing = false);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Reserva creada pero error al cargar detalles: $e', style: GoogleFonts.poppins()),
                                                    backgroundColor: Colors.orange,
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(204, 12, 15, 172),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                                      child: _processing
                                          ? Row(
                                              key: const ValueKey('loading'),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  "Procesando…",
                                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              key: const ValueKey('label'),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.check_circle),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Confirmar reserva",
                                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _obtenerHorasConEstado(ReservaController controller) async {
    if (controller.canchaIdSeleccionada == null || controller.fechaReserva == null) {
      return controller.horas.map((h) => {'hora': h, 'ocupada': false}).toList();
    }

    List<Map<String, dynamic>> horasConEstado = [];
    for (var hora in controller.horas) {
      final disponible = await FirestoreService().verificarDisponibilidad(
        canchaId: controller.canchaIdSeleccionada!,
        fecha: controller.fechaReserva!,
        horaReserva: hora,
      );
      horasConEstado.add({'hora': hora, 'ocupada': !disponible});
    }
    return horasConEstado;
  }
}
