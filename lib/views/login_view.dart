import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/theme_controller.dart';
import '../routes/app_routes.dart';

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
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final themeCtrl = context.watch<ThemeController>();
    final isDark = themeCtrl.isDark;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "lib/images/fondo.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                children: [
                  _DarkModeButton(),
                  const SizedBox(width: 12),
                  _SocialIcon(
                    icon: FontAwesomeIcons.whatsapp,
                    color: Colors.green,
                    onTap: () => _abrirEnlace(
                      "https://wa.me/573003525431",
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 160,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "lib/images/inder.png",
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 20),
    
                      ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              30,
                              30,
                              30,
                              16 + bottomInset,
                            ),
                            decoration: BoxDecoration(
                              color: isDark 
                                ? Colors.black.withOpacity(0.3)
                                : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Bienvenido a",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                ),
                                Text(
                                  "INDER VALLEDUPAR",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Tu mejor aliado para reservar en los mejores escenarios en Valledupar",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3546F0),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.sedes,
                                    ),
                                    child: Text(
                                      "Reservar Cancha",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.loginAdmin,
                                  ),
                                  child: Text(
                                    "Administrador",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 30),
                                Text(
                                  "© 2025 ReservaSports. Todos los derechos reservados.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
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
          ],
        ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(
            color: color.withOpacity(0.6),
            width: 2,
          ),
        ),
        child: FaIcon(
          icon,
          color: color,
          size: 20,
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
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}