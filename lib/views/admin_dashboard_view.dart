// lib/views/admin_dashboard_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/sedes_controller.dart';
import '../routes/app_routes.dart';
import '../services/firestore_service.dart';
import '../widgets/estadistica_card.dart';
import '../widgets/sede_card.dart';
import '../widgets/reserva_item.dart';
import '../widgets/reserva_detalle_sheet.dart';
import '../widgets/sede_form_sheet.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final FirestoreService _firestore = FirestoreService();
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _elapsedText = "00:00";

  List<Map<String, dynamic>> reservasRecientes = [];
  Map<String, dynamic>? estadisticas;
  bool _loadingReservas = true;
  bool _loadingEstadisticas = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _iniciarCronometro();
    
    // ✅ ESCUCHAR CAMBIOS EN TIEMPO REAL EN LAS SEDES
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SedesController>(context, listen: false).escucharSedes();
    });
  }

  void _iniciarCronometro() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final d = _stopwatch.elapsed;
      final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      setState(() => _elapsedText = "$mm:$ss");
    });
  }

  Future<void> _cargarDatos() async {
    await Future.wait([
      _cargarReservas(),
      _cargarEstadisticas(),
    ]);
  }

  Future<void> _cargarReservas() async {
    setState(() => _loadingReservas = true);
    try {
      final reservas = await _firestore.getReservasCompletas();
      if (mounted) {
        setState(() {
          reservasRecientes = reservas;
          _loadingReservas = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar reservas: $e');
      if (mounted) {
        setState(() => _loadingReservas = false);
      }
    }
  }

  Future<void> _cargarEstadisticas() async {
    setState(() => _loadingEstadisticas = true);
    try {
      final stats = await _firestore.getEstadisticasDashboard();
      if (mounted) {
        setState(() {
          estadisticas = stats;
          _loadingEstadisticas = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar estadísticas: $e');
      if (mounted) {
        setState(() => _loadingEstadisticas = false);
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (route) => false);
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _mostrarDetalleReserva(
      Map<String, dynamic> reserva, int index) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFEAEFF3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => ReservaDetalleSheet(
        reserva: reserva,
        onEstadoActualizado: () async {
          await _cargarReservas();
          await _cargarEstadisticas();
          _mostrarSnackbar('Estado de reserva actualizado');
        },
      ),
    );
  }

  Future<void> _mostrarFormularioSede({int? editIndex}) async {
    final controller = Provider.of<SedesController>(context, listen: false);
    final sedeParaEditar = editIndex != null 
        ? controller.customSedes[editIndex] 
        : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SedeFormSheet(
        sedeParaEditar: sedeParaEditar,
        editIndex: editIndex,
        onGuardado: (mensaje) {
          _mostrarSnackbar(mensaje);
          _cargarEstadisticas();
        },
      ),
    );
  }

  Future<void> _confirmarEliminarSede(int customIndex) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar sede'),
        content: const Text('¿Seguro que quieres eliminar esta sede?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await Provider.of<SedesController>(context, listen: false)
            .eliminarSedeCustom(customIndex);
        _mostrarSnackbar('Sede eliminada exitosamente');
        await _cargarEstadisticas();
      } catch (e) {
        _mostrarSnackbar('Error al eliminar: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sedesController = context.watch<SedesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _cargarDatos();
          await sedesController.cargarSedes();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildEstadisticasSection(),
            const SizedBox(height: 24),
            _buildSedesSection(sedesController),
            const SizedBox(height: 24),
            _buildReservasSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioSede(),
        icon: const Icon(Icons.add),
        label: const Text('Crear sede'),
        backgroundColor: const Color(0xFF0083B0),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF0083B0),
      elevation: 0,
      titleSpacing: 0,
      title: const Text(
        "Panel Administrativo",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () async {
            await _cargarDatos();
            await Provider.of<SedesController>(context, listen: false).cargarSedes();
            _mostrarSnackbar('Datos actualizados');
          },
          tooltip: 'Actualizar datos',
        ),
        TextButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: Colors.white),
          label: const Text(
            "Cerrar sesión",
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEstadisticasSection() {
    if (_loadingEstadisticas) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (estadisticas == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estadísticas",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            EstadisticaCard(
              titulo: 'Total Reservas',
              valor: '${estadisticas!['totalReservas'] ?? 0}',
              icono: Icons.event_available,
              color: const Color(0xFF0083B0),
            ),
            EstadisticaCard(
              titulo: 'Sedes',
              valor: '${estadisticas!['totalSedes'] ?? 0}',
              icono: Icons.location_city,
              color: const Color(0xFF2E7D32),
            ),
            EstadisticaCard(
              titulo: 'Pendientes',
              valor: '${estadisticas!['reservasPendientes'] ?? 0}',
              icono: Icons.pending_actions,
              color: const Color(0xFFFFA000),
            ),
            EstadisticaCard(
              titulo: 'Pagadas',
              valor: '${estadisticas!['reservasPagadas'] ?? 0}',
              icono: Icons.check_circle,
              color: const Color(0xFF43A047),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSedesSection(SedesController controller) {
    // ✅ MOSTRAR MENSAJE SI NO HAY SEDES
    if (controller.customSedes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Canchas y sedes",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.location_off, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No hay sedes creadas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona el botón "Crear sede" para agregar una',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Canchas y sedes",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 12),
            itemCount: controller.customSedes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final sede = controller.customSedes[index];

              return SedeCard(
                sede: sede,
                onEditar: () => _mostrarFormularioSede(editIndex: index),
                onEliminar: () => _confirmarEliminarSede(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReservasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reservas recientes",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        if (_loadingReservas)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (reservasRecientes.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay reservas aún',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reservasRecientes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, index) {
              return ReservaItem(
                reserva: reservasRecientes[index],
                onTap: () => _mostrarDetalleReserva(
                  reservasRecientes[index],
                  index,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF0083B0),
            child: Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Admin Andrés Orellano",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            _elapsedText,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}