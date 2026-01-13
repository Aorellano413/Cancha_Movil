// lib/views/sedes_view.dart
import 'dart:io' show File;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _placeholderImage();
        },
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }

    if (!kIsWeb && (path.startsWith('/') || path.contains(':\\'))) {
      return Image.file(
        File(path),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }

    return Image.asset(
      path,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade300, Colors.grey.shade400],
        ),
      ),
      child: const Center(
        child: Icon(Icons.stadium, size: 64, color: Colors.white),
      ),
    );
  }

  String _formatearDistancia(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<SedesController>(context);
    final size = MediaQuery.of(context).size;

    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    final sedesFiltradas = ctrl.sedesConDistancia.where((s) {
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
            child: Column(
              children: [
                _buildCustomAppBar(context, ctrl),
                Expanded(
                  child: ctrl.isLoading || ctrl.buscandoUbicacion
                      ? _buildLoading(ctrl)
                      : ctrl.error != null && ctrl.sedesConDistancia.isEmpty
                      ? _buildErrorView(ctrl)
                      : RefreshIndicator(
                          onRefresh: ctrl.cargarSedes,
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    10,
                                  ),
                                  child: _buildSearchBar(),
                                ),
                              ),
                              if (ctrl.ordenarPorDistancia)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      10,
                                      20,
                                      10,
                                    ),
                                    child: _buildDistanceIndicator(ctrl),
                                  ),
                                ),
                              if (sedesFiltradas.isEmpty)
                                SliverFillRemaining(child: _buildEmptyState())
                              else
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    isDesktop ? 40 : 20,
                                    20,
                                    isDesktop ? 40 : 20,
                                    20,
                                  ),
                                  sliver: SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isDesktop
                                              ? 3
                                              : (isTablet ? 2 : 1),
                                          childAspectRatio: isDesktop
                                              ? 1.25
                                              : (isTablet ? 1.15 : 1.05),

                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                        ),
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final item = sedesFiltradas[index];
                                      return _buildSedeCard(
                                        context,
                                        item.sede,
                                        item.distanciaKm,
                                      );
                                    }, childCount: sedesFiltradas.length),
                                  ),
                                ),
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

  Widget _buildSedeCard(
    BuildContext context,
    SedeModel sede,
    double? distanciaKm,
  ) {
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
                if (sede.id == null) {
                  _showSnackBar('Error: Sede sin ID', Colors.red);
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CanchasView(sedeId: sede.id!, sedeNombre: sede.title),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: _buildSedeImage(sede.imagePath),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: _badge(sede.tag, const Color.fromARGB(255, 0, 0, 0)),
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sede.title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.place, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sede.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3546F0),
                                borderRadius: BorderRadius.circular(12),
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
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ],
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
        ],
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

  Widget _buildCustomAppBar(BuildContext context, SedesController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              'Sedes Disponibles',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              ctrl.ordenarPorDistancia ? Icons.clear_all : Icons.my_location,
              color: Colors.white,
            ),
            onPressed: () async {
              if (ctrl.ordenarPorDistancia) {
                ctrl.resetearOrden();
              } else {
                await ctrl.buscarSedesCercanas();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: ctrl.cargarSedes,
          ),
        ],
      ),
    );
  }

 Widget _buildSearchBar() {
  final width = MediaQuery.of(context).size.width;

  return Center(
    child: SizedBox(
      width: width > 900 ? 520 : (width > 600 ? 420 : width * 0.9),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar sede...',
              hintStyle: GoogleFonts.poppins(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildDistanceIndicator(SedesController ctrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 53, 70, 240).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.near_me, color: Colors.white),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Mostrando sedes más cercanas',
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: ctrl.resetearOrden,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(SedesController ctrl) {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildErrorView(SedesController ctrl) {
    return const Center(child: Text('Error al cargar sedes'));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        _query.isEmpty ? 'No hay sedes disponibles' : 'No se encontraron sedes',
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}
