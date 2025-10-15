import 'dart:io' show File; // OK en móvil/desktop; en web se ignora
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/sedes_controller.dart';
import '../models/sede_model.dart';
import '../routes/app_routes.dart';

class SedesView extends StatefulWidget {
  const SedesView({super.key});

  @override
  State<SedesView> createState() => _SedesViewState();
}

class _SedesViewState extends State<SedesView> {
  String _query = '';

  Widget _imageFor(String path) {
    // 1) blob:/http/https (web o urls) -> network
    if (path.startsWith('blob:') || path.startsWith('http')) {
      return Image.network(
        path,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    // 2) rutas locales (Android/iOS/desktop) -> file
    if (path.startsWith('/') || path.contains(':\\')) {
      return Image.file(
        File(path),
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    // 3) por defecto tratamos como asset
    return Image.asset(
      path,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar sede...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 20),
          if (sedesFiltradas.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'No se encontraron sedes.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ...sedesFiltradas.map((sede) => _buildSedeCard(context, sede)),
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
          if (sede.title.contains('Principal')) {
            Navigator.pushNamed(context, AppRoutes.inicioJugada);
          } else if (sede.title.contains('Secundaria')) {
            Navigator.pushNamed(context, AppRoutes.inicioJugada2);
          } else if (sede.title.contains('Biblos')) {
            Navigator.pushNamed(context, AppRoutes.inicioBiblos);
          } else if (sede.title.contains('Fortín')) {
            Navigator.pushNamed(context, AppRoutes.inicioFortin);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: _imageFor(sede.imagePath),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sede.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    sede.subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // (Descripción removida como pediste)
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sede.price,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        sede.tag,
                        style: const TextStyle(color: Colors.green),
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
