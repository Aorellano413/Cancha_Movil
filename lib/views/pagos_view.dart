// lib/views/pagos_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PagosView extends StatelessWidget {
  const PagosView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('No se encontraron datos de la reserva'),
        ),
      );
    }

    // Extraer datos reales
    final String nombre = args['nombreCompleto'] ?? 'Sin nombre';
    final String correo = args['correoElectronico'] ?? 'Sin correo';
    final String numero = args['numeroCelular'] ?? 'Sin teléfono';
    final String hora = args['horaReserva'] ?? 'Sin hora';
    final String sede = args['sedeNombre'] ?? 'Sin sede';
    final String cancha = args['canchaNombre'] ?? 'Sin cancha';
    final String monto = args['precio'] ?? '0';
    final DateTime? fecha = args['fechaReserva'];

    final String fechaTexto = fecha != null
        ? '${fecha.day}/${fecha.month}/${fecha.year}'
        : 'Sin fecha';

    const String whatsAppEmpresa = "3007437404";

    Future<void> _enviarWhatsApp() async {
      final String mensaje = """
🏆 *INDER - VALLEDUPAR*

📋 *Datos del Cliente:*
👤 *Nombre:* $nombre
✉️ *Correo:* $correo
📞 *Teléfono:* $numero
📍 *Sede:* $sede
⚽ *Cancha:* $cancha
📅 *Fecha:* $fechaTexto
🕒 *Hora:* $hora
💰 *Valor total:* \$$monto

📤 *Mandar comprobante de pago a la empresa.*
💬 *Método de pago:* Nequi - Bancolombia - Daviplata
""";

      final Uri uriWhatsapp = Uri.parse(
        "https://wa.me/57$whatsAppEmpresa?text=${Uri.encodeComponent(mensaje)}",
      );

      await launchUrl(uriWhatsapp, mode: LaunchMode.externalApplication);
    }

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
                          onPressed: () {
                            // Regresar hasta la vista de sedes (elimina todas las vistas anteriores)
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Opciones de Pago',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contenido principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Detalles de la reserva
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.receipt_long, color: Colors.white, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Detalles de la Reserva",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _dato("👤 Nombre", nombre),
                                  _dato("✉️ Correo", correo),
                                  _dato("📞 Teléfono", numero),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Divider(
                                      color: Colors.white.withOpacity(0.3),
                                      thickness: 1,
                                    ),
                                  ),

                                  _dato("📅 Fecha", fechaTexto),
                                  _dato("🕒 Hora", hora),
                                  _dato("📍 Sede", sede),
                                  _dato("⚽ Cancha", cancha),

                                  const SizedBox(height: 16),

                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(204, 12, 15, 172),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "💰 Total a pagar:",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          "\$$monto",
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Título métodos de pago
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 16),
                          child: Text(
                            "Seleccione método de pago",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Botón WhatsApp
                        _botonPago(
                          context,
                          icono: Icons.chat,
                          titulo: "Pagar por WhatsApp",
                          descripcion: "Enviar detalles y comprobante por WhatsApp",
                          color: const Color(0xFF25D366),
                          onPressed: _enviarWhatsApp,
                        ),

                        const SizedBox(height: 16),

                        // Botón Pago en línea
                        _botonPago(
                          context,
                          icono: Icons.credit_card,
                          titulo: "Pago en Línea",
                          descripcion: "Pagar con tarjeta débito o crédito",
                          color: const Color.fromARGB(204, 12, 15, 172),
                          onPressed: () {
                            // TODO: Implementar pasarela de pagos
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Próximamente disponible',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Nota informativa
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade200),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Recuerde enviar el comprobante de pago para confirmar su reserva.",
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              titulo,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonPago(
    BuildContext context, {
    required IconData icono,
    required String titulo,
    required String descripcion,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icono, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}