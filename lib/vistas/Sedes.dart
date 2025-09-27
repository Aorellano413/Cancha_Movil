import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../routes/app_routes.dart';

class SedesPage extends StatelessWidget {
  const SedesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage("assets/img/ball.jpg"),
              radius: 16,
            ),
            const SizedBox(width: 8),
            const Text("ReservaSports",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar sede...",
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 20),
          const Text("Sedes Disponibles",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          CustomCard(
            title: "Sede - La Jugada",
            subtitle: "Mayales, Valledupar",
            price: 60000,
            image: "assets/img/stadium1.jpg",
            onTap: () => Navigator.pushNamed(context, AppRoutes.inicio),
          ),
          CustomCard(
            title: "Sede - Biblos",
            subtitle: "Sabanas, Valledupar",
            price: 70000,
            image: "assets/img/stadium2.jpg",
            onTap: () => Navigator.pushNamed(context, AppRoutes.inicio),
          ),
        ],
      ),
    );
  }
}
