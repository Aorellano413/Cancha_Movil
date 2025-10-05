import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/sedes_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_card.dart';

class SedesView extends StatelessWidget {
  const SedesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecciona una Sede"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Regresa a Login
        ),
      ),
      body: Consumer<SedesController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.sedes.length,
                    itemBuilder: (context, index) {
                      final sede = controller.sedes[index];
                      return CustomCard(
                        imagePath: sede.imagePath,
                        title: sede.title,
                        subtitle: sede.subtitle,
                        price: sede.price,
                        tag: sede.tag,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.inicio); // Apila Inicio
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
