// lib/views/propietario_canchas_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/canchas_controller.dart';
import '../models/cancha_model.dart';
import '../widgets/cancha_form_sheet.dart';

class PropietarioCanchasView extends StatefulWidget {
  const PropietarioCanchasView({super.key});

  @override
  State<PropietarioCanchasView> createState() => _PropietarioCanchasViewState();
}

class _PropietarioCanchasViewState extends State<PropietarioCanchasView> {
  late CanchasController _canchasController;
  String? _sedeId;

  @override
  void initState() {
    super.initState();
    _canchasController = CanchasController();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    _sedeId = authController.currentUser?.sedeAsignada;

    if (_sedeId != null) {
      await _canchasController.cargarCanchasPorSede(_sedeId!);
    }
  }

  @override
  void dispose() {
    _canchasController.dispose();
    super.dispose();
  }

  void _mostrarFormulario({CanchaModel? cancha}) async {
    if (_sedeId == null) {
      _mostrarSnackbar('Error: No se encontró la sede asignada');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CanchaFormSheet(
        sedeId: _sedeId!,
        canchaParaEditar: cancha,
        onGuardado: () async {
          await _canchasController.cargarCanchasPorSede(_sedeId!);
          if (mounted) {
            Navigator.pop(ctx);
            _mostrarSnackbar(
              cancha == null ? 'Cancha creada exitosamente' : 'Cancha actualizada',
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmarEliminar(CanchaModel cancha) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cancha'),
        content: Text('¿Está seguro de eliminar "${cancha.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && cancha.id != null) {
      try {
        await _canchasController.eliminarCancha(cancha.id!);
        _mostrarSnackbar('Cancha eliminada exitosamente');
      } catch (e) {
        _mostrarSnackbar('Error al eliminar: $e');
      }
    }
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _canchasController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Canchas'),
          backgroundColor: const Color(0xFF0083B0),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                if (_sedeId != null) {
                  await _canchasController.cargarCanchasPorSede(_sedeId!);
                  _mostrarSnackbar('Canchas actualizadas');
                }
              },
              tooltip: 'Actualizar',
            ),
          ],
        ),
        body: Consumer<CanchasController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        controller.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_sedeId != null) {
                          await controller.cargarCanchasPorSede(_sedeId!);
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (controller.canchas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No hay canchas registradas',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crea tu primera cancha',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (_sedeId != null) {
                  await controller.cargarCanchasPorSede(_sedeId!);
                }
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.canchas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  final cancha = controller.canchas[index];
                  return _CanchaCard(
                    cancha: cancha,
                    onEditar: () => _mostrarFormulario(cancha: cancha),
                    onEliminar: () => _confirmarEliminar(cancha),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrarFormulario(),
          icon: const Icon(Icons.add),
          label: const Text('Crear Cancha'),
          backgroundColor: const Color(0xFF0083B0),
        ),
      ),
    );
  }
}

// ============ CARD DE CANCHA ============

class _CanchaCard extends StatelessWidget {
  final CanchaModel cancha;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _CanchaCard({
    required this.cancha,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.asset(
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
                // Tipo de cancha tag
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTipoText(cancha.tipo),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Información
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cancha.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      cancha.horario,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      cancha.jugadores,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEditar,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0083B0),
                          side: const BorderSide(color: Color(0xFF0083B0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEliminar,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTipoText(TipoCancha tipo) {
    switch (tipo) {
      case TipoCancha.abierta:
        return 'Abierta';
      case TipoCancha.cerrada:
        return 'Cerrada';
      case TipoCancha.natural:
        return 'Natural';
      case TipoCancha.techada:
        return 'Techada';
      case TipoCancha.sintetica:
        return 'Sintética';
    }
  }
}