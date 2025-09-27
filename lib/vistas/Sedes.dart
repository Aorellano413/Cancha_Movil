import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../routes/app_routes.dart';

class SedesScreen extends StatelessWidget {
  const SedesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
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
            const Text("Sedes Disponibles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CustomCard(
              imagePath: "assets/images/stadium1.jpg",
              title: "Sede - La Jugada",
              subtitle: "Mayales, Valledupar",
              price: "\$60.000",
              tag: "Día - Noche",
              onTap: () => Navigator.pushNamed(context, AppRoutes.inicio),
            ),
            CustomCard(
              imagePath: "assets/images/stadium2.jpg",
              title: "Sede - Biblos",
              subtitle: "Sabanas, Valledupar",
              price: "\$70.000",
              tag: "Día - Noche",
              onTap: () => Navigator.pushNamed(context, AppRoutes.inicio),
            ),
          ],
        ),
      ),
    );
  }
}
