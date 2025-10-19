// lib/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/theme_controller.dart';
import '../controllers/sedes_controller.dart';
import '../routes/app_routes.dart';
import '../utils/populate_firestore.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> _abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'No se pudo abrir $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final List<String> imagenes = [
      "lib/images/1.jpg",
      "lib/images/2.jpg",
      "lib/images/3.jpg",
      "lib/images/4.jpg",
      "lib/images/5.jpg",
      "lib/images/6.jpg",
      "lib/images/7.jpg",
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final bottomInset = MediaQuery.of(context).viewPadding.bottom;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: h * 0.58,
                      child: Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: double.infinity,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 4),
                              viewportFraction: 1.0,
                              enableInfiniteScroll: true,
                              scrollDirection: Axis.horizontal,
                            ),
                            items: imagenes.map((imagen) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(imagen, fit: BoxFit.cover),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.6),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          // ====== ICONOS LATERALES: MODO OSCURO + REDES ======
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Column(
                              children: [
                                _DarkModeButton(),
                                const SizedBox(height: 12),
                                _SocialIcon(
                                  icon: FontAwesomeIcons.whatsapp,
                                  color: Colors.green,
                                  onTap: () =>
                                      _abrirEnlace("https://wa.me/573003525431"),
                                ),
                                const SizedBox(height: 12),
                                _SocialIcon(
                                  icon: FontAwesomeIcons.instagram,
                                  color: Colors.purple,
                                  onTap: () => _abrirEnlace(
                                      "https://www.instagram.com/reservasports_co"),
                                ),
                                const SizedBox(height: 12),
                                _SocialIcon(
                                  icon: FontAwesomeIcons.facebook,
                                  color: Colors.blue,
                                  onTap: () => _abrirEnlace(
                                      "https://www.facebook.com/profile.php?id=61577803655371"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(30, 30, 30, 16 + bottomInset),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(40)),
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Bienvenido a",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "ReservaSports",
                            style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Tu mejor aliado para reservar las mejores canchas en Valledupar",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Botón principal
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                elevation: 5,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.sedes),
                              child: Text(
                                "Reservar Cancha",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.loginAdmin),
                            child: Text(
                              "Administrador",
                              style: GoogleFonts.poppins(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // ====== BOTÓN TEMPORAL PARA POBLAR DATOS ======
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            "Herramientas de desarrollo",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              _DevButton(
                                icon: Icons.cloud_upload,
                                label: "Poblar DB",
                                color: Colors.green,
                                onPressed: () async {
                                  _showLoadingDialog(context);
                                  try {
                                    await PopulateFirestore.poblarDatosIniciales();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      Provider.of<SedesController>(context, listen: false)
                                          .cargarSedes();
                                      _showSuccessDialog(context,
                                          "Datos poblados exitosamente");
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showErrorDialog(context,
                                          "Error al poblar datos: $e");
                                    }
                                  }
                                },
                              ),
                              _DevButton(
                                icon: Icons.analytics,
                                label: "Ver Stats",
                                color: Colors.blue,
                                onPressed: () async {
                                  _showLoadingDialog(context);
                                  try {
                                    await PopulateFirestore.mostrarEstadisticas();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showSuccessDialog(context,
                                          "Estadísticas mostradas en consola");
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showErrorDialog(context,
                                          "Error al obtener estadísticas: $e");
                                    }
                                  }
                                },
                              ),
                              _DevButton(
                                icon: Icons.event,
                                label: "Reservas Demo",
                                color: Colors.orange,
                                onPressed: () async {
                                  _showLoadingDialog(context);
                                  try {
                                    await PopulateFirestore.crearReservasEjemplo();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showSuccessDialog(
                                          context, "Reservas demo creadas");
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _showErrorDialog(context,
                                          "Error al crear reservas: $e");
                                    }
                                  }
                                },
                              ),
                              _DevButton(
                                icon: Icons.delete_forever,
                                label: "Limpiar DB",
                                color: Colors.red,
                                onPressed: () {
                                  _showConfirmDialog(
                                    context,
                                    title: "⚠️ Advertencia",
                                    message:
                                        "¿Estás seguro? Esto eliminará TODOS los datos de la base de datos.",
                                    onConfirm: () async {
                                      _showLoadingDialog(context);
                                      try {
                                        await PopulateFirestore.limpiarBaseDatos();
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          Provider.of<SedesController>(context, listen: false)
                                              .cargarSedes();
                                          _showSuccessDialog(
                                              context, "Base de datos limpiada");
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          _showErrorDialog(context,
                                              "Error al limpiar: $e");
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),

                          // ====== PIE DE PÁGINA RESERVASPORTS ======
                          const SizedBox(height: 30),
                          Text(
                            "© 2025 ReservaSports. Todos los derechos reservados.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Procesando..."),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Éxito"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }
}
class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: FaIcon(
          icon,
          color: color,
          size: 22,
        ),
      ),
    );
  }
}
class _DarkModeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();
    final isDark = themeCtrl.isDark;

    return InkWell(
      onTap: themeCtrl.toggle,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: Colors.white,
        ),
      ),
    );
  }
}
class _DevButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DevButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
