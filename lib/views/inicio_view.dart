// views/inicio_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/canchas_controller.dart';
import '../controllers/reserva_controller.dart';
import '../models/cancha_model.dart';
import '../routes/app_routes.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CanchasController()),
        
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Inicio"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer2<CanchasController, ReservaController>(
          builder: (context, canchasController, reservaController, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "¡Reserva tu mejor cancha!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ...canchasController.canchas.map((cancha) {
                  return _buildCard(
                      context,
                      cancha: cancha,
                      reservaController: reservaController);
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required CanchaModel cancha,
    required ReservaController reservaController,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              cancha.image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cancha.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(cancha.horario,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(cancha.price,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      
                      reservaController.setTipoCancha(cancha.tipo); 
                      Navigator.pushNamed(context, AppRoutes.reserva);
                    },
                    child: const Text("Reservar",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
