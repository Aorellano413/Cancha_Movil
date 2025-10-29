// lib/views/pagos_view.dart
import 'package:flutter/material.dart';
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
🏆 *ReservaSport*

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
💬 *Método de pago:* Nequi
""";

      final Uri uriWhatsapp = Uri.parse(
        "https://wa.me/57$whatsAppEmpresa?text=${Uri.encodeComponent(mensaje)}",
      );

      await launchUrl(uriWhatsapp, mode: LaunchMode.externalApplication);
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          "Opciones de Pago",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Detalles de la Reserva",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dato("👤 Nombre", nombre, textColor),
                  _dato("✉️ Correo", correo, textColor),
                  _dato("📞 Teléfono", numero, textColor),
                  const Divider(height: 30, thickness: 0.8),
                  _dato("📅 Fecha", fechaTexto, textColor),
                  _dato("🕒 Hora", hora, textColor),
                  _dato("📍 Sede", sede, textColor),
                  _dato("⚽ Cancha", cancha, textColor),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "💰 Monto Total:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "\$$monto",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Elegir Método de Pago",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _metodoPago(
              context,
              color: Colors.green[600]!,
              icon: Icons.attach_money,
              titulo: "Pago en Efectivo",
              descripcion: "Debe acercarse a la cancha para realizar el pago.",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text("Pago en Efectivo"),
                    content: Text(
                      "Debe acercarse a la cancha *$sede* para realizar el pago en efectivo. "
                      "Recuerde mencionar su reserva a nombre de *$nombre*.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cerrar"),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _metodoPago(
              context,
              color: Colors.purple[700]!,
              icon: Icons.phone_android,
              titulo: "WhatsApp de la empresa",
              descripcion:
                  "Enviar detalles de la reserva a la empresa por WhatsApp.",
              onPressed: _enviarWhatsApp,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              titulo,
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              valor,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metodoPago(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String titulo,
    required String descripcion,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}