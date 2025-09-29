import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../routes/app_routes.dart';

class SedesScreen extends StatefulWidget {
  const SedesScreen({super.key});

  @override
  State<SedesScreen> createState() => _SedesScreenState();
}

class _SedesScreenState extends State<SedesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _sedes = [
    {
      "image": "assets/images/stadium1.jpg",
      "title": "Sede - La Jugada",
      "subtitle": "Mayales, Valledupar",
      "price": "\$70.000",
      "tag": "Día - Noche",
    },
    {
      "image": "assets/images/stadium2.jpg",
      "title": "Sede - Biblos",
      "subtitle": "Sabanas, Valledupar",
      "price": "\$70.000",
      "tag": "Día - Noche",
    },
  ];

  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSedes = _sedes.where((sede) {
      final title = sede["title"]!.toLowerCase();
      final subtitle = sede["subtitle"]!.toLowerCase();
      return title.contains(_searchText) || subtitle.contains(_searchText);
    }).toList();

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
        child: Column(
          children: [
            TextField(
              controller: _searchController,
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Sedes Disponibles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSedes.length,
                itemBuilder: (context, index) {
                  final sede = filteredSedes[index];
                  return CustomCard(
                    imagePath: sede["image"]!,
                    title: sede["title"]!,
                    subtitle: sede["subtitle"]!,
                    price: sede["price"]!,
                    tag: sede["tag"]!,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.inicio),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
