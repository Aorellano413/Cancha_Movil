import 'dart:io' show File;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/sedes_controller.dart';
import '../models/sede_model.dart';
import 'canchas_view.dart';

class SedesView extends StatefulWidget {
  const SedesView({super.key});

  @override
  State<SedesView> createState() => _SedesViewState();
}

class _SedesViewState extends State<SedesView> {
  String _query = '';

  Widget _buildSedeImage(String path) {
    Widget imageWidget;

    if (path.startsWith('http')) {
      imageWidget = Image.network(
        path,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && (path.startsWith('/') || path.contains(':\\'))) {
      imageWidget = Image.file(
        File(path),
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        path,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: imageWidget,
    );
  }

  String _formatearDistancia(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  void abrirMaps(String direccion) {
    if (kIsWeb) {
      launchUrl(Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$direccion',
      ));
    } else {
      MapsLauncher.launchQuery(direccion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<SedesController>(context);
    final width = MediaQuery.of(context).size.width;

    final isDesktop = width > 900;
    final isTablet = width > 600 && width <= 900;

    final sedes = ctrl.sedesConDistancia.where((s) {
      return s.sede.title.toLowerCase().contains(_query.toLowerCase()) ||
          s.sede.subtitle.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("lib/images/fondo.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildCustomAppBar()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(),
                  ),
                ),

                if (ctrl.isLoading)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  )

                else if (sedes.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          "No existe esa sede",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )

                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 20,
                      vertical: 20,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = sedes[index];
                          return _buildSedeCard(
                            context,
                            item.sede,
                            item.distanciaKm,
                          );
                        },
                        childCount: sedes.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio:
                            isDesktop ? 1.20 : (isTablet ? 1.10 : 0.95),
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

  Widget _buildSedeCard(
      BuildContext context, SedeModel sede, double? distanciaKm) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CanchasView(
                      sedeId: sede.id!,
                      sedeNombre: sede.title,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: _buildSedeImage(sede.imagePath),
                      ),
                      if (distanciaKm != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _badge(
                            _formatearDistancia(distanciaKm),
                            Colors.blue.shade700,
                            icon: Icons.location_on,
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _badge(
                            sede.tag, const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sede.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => abrirMaps(sede.subtitle),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.place,
                                        size: 16,
                                        color: Colors.blue.shade300),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        sede.subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.blue.shade300,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(204, 12, 15, 172),
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: Text(
                                  sede.price,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            'Sedes Disponibles',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Buscar sede...',
        hintStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (v) => setState(() => _query = v),
    );
  }
}
