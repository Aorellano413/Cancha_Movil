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

  /// Mapeo de nombres a imágenes locales
  final Map<String, String> _imageMap = {
    'biblos': 'lib/images/biblos.jpg',
    'fortín': 'lib/images/fortin.jpg',
    'fortin': 'lib/images/fortin.jpg',
    'hechizo': 'lib/images/hechizo.jpg',
    'ftecho': 'lib/images/ftecho.jpg',
    'jugada': 'lib/images/jugada.jpg',
    'j2': 'lib/images/j2.jpg',
    'j3': 'lib/images/j3.jpg',
    'jsintecho': 'lib/images/jsintecho.jpg',
    'logosintesports': 'lib/images/logosintesports.jpg',
    'sede2': 'lib/images/sede2.jpg',
    'sintecho': 'lib/images/sintecho.jpg',
    'techo': 'lib/images/techo.jpg',
    'secundaria': 'lib/images/1.jpg',
    'la jugada': 'lib/images/jugada.jpg',
  };

  Widget _imageFor(String path, String title) {
    // Buscar imagen por nombre de sede
    String imagePath = path;
    
    // Si el path está vacío o es inválido, buscar por título
    if (path.isEmpty || (!path.startsWith('http') && !path.startsWith('lib/'))) {
      final titleLower = title.toLowerCase();
      
      // Buscar coincidencia exacta o parcial
      for (var entry in _imageMap.entries) {
        if (titleLower.contains(entry.key)) {
          imagePath = entry.value;
          break;
        }
      }
      
      // Si no encontró, usar imagen por defecto
      if (imagePath.isEmpty || imagePath == path) {
        imagePath = 'lib/images/sede2.jpg';
      }
    }
    
    // URLs (web o network)
    if (imagePath.startsWith('blob:') || imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    }
    
    // Rutas locales (Android/iOS/desktop)
    if (!kIsWeb && (imagePath.startsWith('/') || imagePath.contains('\\'))) {
      return Image.file(
        File(imagePath),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage();
        },
      );
    }
    
    // Assets (default)
    return Image.asset(
      imagePath,
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

  void _mostrarOpcionesOrdenamiento(SedesController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ordenar por',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Sin ordenar'),
              trailing: controller.ordenamiento == 'ninguno'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                controller.cambiarOrdenamiento('ninguno');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.near_me),
              title: const Text('Más cercanas'),
              subtitle: controller.currentPosition == null
                  ? const Text('Requiere acceso a ubicación', style: TextStyle(fontSize: 12))
                  : null,
              trailing: controller.ordenamiento == 'distancia'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await controller.ordenarPorDistancia();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Nombre'),
              trailing: controller.ordenamiento == 'nombre'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                controller.cambiarOrdenamiento('nombre');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sedesController = Provider.of<SedesController>(context);

    final sedesFiltradas = sedesController.sedes
        .where((sede) =>
            sede.title.toLowerCase().contains(_query.toLowerCase()) ||
            sede.subtitle.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sedes disponibles'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _mostrarOpcionesOrdenamiento(sedesController),
            tooltip: 'Ordenar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => sedesController.cargarSedes(),
            tooltip: 'Actualizar sedes',
          ),
        ],
      ),
      body: sedesController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sedesController.error != null
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
              : Stack(
                  children: [
                    RefreshIndicator(
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
                          const SizedBox(height: 12),
                          
                          // Chip de ordenamiento actual
                          if (sedesController.ordenamiento != 'ninguno')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Chip(
                                avatar: Icon(
                                  sedesController.ordenamiento == 'distancia'
                                      ? Icons.near_me
                                      : Icons.sort_by_alpha,
                                  size: 16,
                                ),
                                label: Text(
                                  sedesController.ordenamiento == 'distancia'
                                      ? 'Ordenado por distancia'
                                      : 'Ordenado alfabéticamente',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.green.shade100,
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => sedesController.cambiarOrdenamiento('ninguno'),
                              ),
                            ),
                          
                          const SizedBox(height: 8),
                          
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
                            ...sedesFiltradas.map((sede) => _buildSedeCard(context, sede)),
                        ],
                      ),
                    ),
                    
                    // Indicador de carga de ubicación
                    if (sedesController.isLoadingLocation)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.blue.shade100,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Obteniendo tu ubicación...',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildSedeCard(BuildContext context, SedeModel sede) {
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
                  child: _imageFor(sede.imagePath, sede.title),
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
                // Badge de distancia
                if (sede.distanceInKm != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.near_me, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${sede.distanceInKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
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