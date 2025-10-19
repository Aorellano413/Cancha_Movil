// lib/views/canchas_view.dart (Vista genérica para cualquier sede)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/canchas_controller.dart';
import '../controllers/reserva_controller.dart';
import '../models/cancha_model.dart';
import '../routes/app_routes.dart';

class CanchasView extends StatefulWidget {
  final String sedeId;
  final String sedeNombre;

  const CanchasView({
    super.key,
    required this.sedeId,
    required this.sedeNombre,
  });

  @override
  State<CanchasView> createState() => _CanchasViewState();
}

class _CanchasViewState extends State<CanchasView> {
  late CanchasController _canchasController;

  @override
  void initState() {
    super.initState();
    _canchasController = CanchasController();
    _canchasController.cargarCanchasPorSede(widget.sedeId);
  }

  @override
  void dispose() {
    _canchasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _canchasController,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.sedeNombre),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer2<CanchasController, ReservaController>(
          builder: (context, canchasController, reservaController, child) {
            if (canchasController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (canchasController.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar canchas',
                      style: TextStyle(fontSize: 18, color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      canchasController.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => canchasController.cargarCanchasPorSede(widget.sedeId),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (canchasController.canchas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No hay canchas disponibles',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pronto habrá más opciones',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => canchasController.cargarCanchasPorSede(widget.sedeId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    "¡Reserva tu cancha en ${widget.sedeNombre}!",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...canchasController.canchas.map((cancha) {
                    return _buildCard(
                      context,
                      cancha: cancha,
                      reservaController: reservaController,
                    );
                  }),
                ],
              ),
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
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              cancha.image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cancha.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              cancha.horario,
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.sports_soccer, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              "Jugadores: ${cancha.jugadores}",
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cancha.price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      reservaController.setTipoCancha(cancha.tipo);
                      reservaController.setCanchaId(cancha.id);
                      reservaController.setSedeId(widget.sedeId);
                      Navigator.pushNamed(context, AppRoutes.reserva);
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text(
                      "Reservar",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}