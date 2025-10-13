// views/pagos_view.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PagosView extends StatelessWidget {
  const PagosView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🧍 Datos del cliente
    const String nombre = "Adel Andres Orellano Villegas";
    const String correo = "andresorellano591@gmail.com";
    const String numero = "3003525431"; 
    const String hora = "17:00 - 18:00";
    const String sede = "La Jugada Principal";
    const String cancha = "Cancha techada";
    const String monto = "80.000";

  
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
🕒 *Hora:* $hora
💰 *Valor total:* \$$monto pesos

📤 *Mandar comprobante de pago a la empresa.*
💬 *Método de pago:* Nequi
""";

      final Uri uriWhatsapp = Uri.parse(
        "https://wa.me/57$whatsAppEmpresa?text=${Uri.encodeComponent(mensaje)}",
      );

      await launchUrl(uriWhatsapp, mode: LaunchMode.externalApplication);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Opciones de Pago",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detalles de la Reserva",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _dato("👤 Nombre", nombre),
                  _dato("✉️ Correo", correo),
                  _dato("📞 Teléfono", numero),
                  const Divider(height: 30, thickness: 0.8),
                  _dato("🕒 Hora", hora),
                  _dato("📍 Sede", sede),
                  _dato("⚽ Cancha", cancha),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "💰 Monto Total:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                        borderRadius: BorderRadius.circular(16)),
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

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child:
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 5,
            child: Text(valor,
                style:
                    const TextStyle(fontSize: 16, color: Colors.black87)),
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
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
