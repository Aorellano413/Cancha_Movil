// views/sedes_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/sedes_controller.dart';
import '../widgets/custom_card.dart';
import '../routes/app_routes.dart';

class SedesView extends StatelessWidget {
  const SedesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SedesController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ReservaSports"),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<SedesController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Buscador
                  TextField(
                    onChanged: controller.buscarSedes,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Buscar sede...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Título
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sedes Disponibles",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Lista de sedes
                  Expanded(
                    child: controller.sedes.isEmpty
                        ? const Center(
                            child: Text(
                              "No se encontraron sedes",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.sedes.length,
                            itemBuilder: (context, index) {
                              final sede = controller.sedes[index];
                              return CustomCard(
                                imagePath: sede.imagePath,
                                title: sede.title,
                                subtitle: sede.subtitle,
                                price: sede.price,
                                tag: sede.tag,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.inicio,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}