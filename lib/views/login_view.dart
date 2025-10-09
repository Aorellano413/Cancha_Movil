import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_routes.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imagenes = [
      "lib/images/1.jpg",
      "lib/images/2.jpg",
      "lib/images/3.jpg",
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          
          Expanded(
            flex: 2,
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
                    return Builder(
                      builder: (BuildContext context) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              imagen,
                              fit: BoxFit.cover, 
                            ),
                            
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
                      },
                    );
                  }).toList(),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  child: Text(
                    "\n",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 👋 Sección inferior de bienvenida
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bienvenido a",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "ReservaSports",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Tu mejor aliado para practicar fútbol en Valledupar",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🔘 Botón de Usuario
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.sedes);
                    },
                    child: Text(
                      "Usuario",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 🔐 Texto para admin
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.sedes);
                    },
                    child: Text(
                      " Administrador",
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
