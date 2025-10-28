// lib/views/sedes_view.dart
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 180,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    }

    if (!kIsWeb && (path.startsWith('/') || path.contains(':\\'))) {
      return Image.file(
        File(path),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    }

    return Image.asset(
      path,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _placeholderImage();
      },
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 180,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.stadium, size: 64, color: Colors.grey),
      ),
    );
  }

  String _formatearDistancia(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    } else {
      return '${km.toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedesController = Provider.of<SedesController>(context);

    final sedesFiltradas = sedesController.sedesConDistancia
        .where((sedeConDist) =>
            sedeConDist.sede.title.toLowerCase().contains(_query.toLowerCase()) ||
            sedeConDist.sede.subtitle.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedes disponibles'),
        centerTitle: true,
        actions: [
          Consumer<SedesController>(
            builder: (context, controller, _) {
              if (controller.ordenarPorDistancia) {
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Ver todas las sedes',
                  onPressed: () => controller.resetearOrden(),
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.my_location),
                  tooltip: 'Buscar cerca de mí',
                  onPressed: () async {
                    await controller.buscarSedesCercanas();
                    
                    if (controller.error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(controller.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Sedes ordenadas por distancia'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => sedesController.cargarSedes(),
            tooltip: 'Actualizar sedes',
          ),
        ],
      ),
      body: sedesController.isLoading || sedesController.buscandoUbicacion
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    sedesController.buscandoUbicacion
                        ? 'Buscando sedes cercanas...'
                        : 'Cargando sedes...',
                  ),
                ],
              ),
            )
          : sedesController.error != null && sedesController.sedesConDistancia.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar sedes',
                        style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          sedesController.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => sedesController.cargarSedes(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => sedesController.cargarSedes(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar sede...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                      
                      if (sedesController.ordenarPorDistancia)
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.near_me, color: Colors.blue.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mostrando sedes más cercanas primero',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => sedesController.resetearOrden(),
                                tooltip: 'Quitar filtro',
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      if (sedesFiltradas.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  _query.isEmpty
                                      ? 'No hay sedes disponibles'
                                      : 'No se encontraron sedes',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...sedesFiltradas.map((sedeConDist) => 
                          _buildSedeCard(context, sedeConDist.sede, sedeConDist.distanciaKm)
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSedeCard(BuildContext context, SedeModel sede, double? distanciaKm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (sede.id == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: Sede sin ID'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CanchasView(
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildSedeImage(sede.imagePath),
                ),
                
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      sede.tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                if (distanciaKm != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatearDistancia(distanciaKm),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sede.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.place, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sede.subtitle,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sede.price,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}