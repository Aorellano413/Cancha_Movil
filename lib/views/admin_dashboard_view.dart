// lib/views/admin_dashboard_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
      if (mounted) setState(() => _loadingReservas = false);
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
      if (mounted) setState(() => _loadingEstadisticas = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _mostrarDetalleReserva(Map<String, dynamic> reserva, int index) async {
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
    final sedeParaEditar = editIndex != null ? controller.customSedes[editIndex] : null;

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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
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

  Map<String, int> _contarReservasPorSede() {
    final Map<String, int> conteo = {};

    for (var reserva in reservasRecientes) {
      String sede = 'Sin sede';
      
      if (reserva['sede'] != null) {
        if (reserva['sede'] is Map) {
          sede = reserva['sede']['nombre'] ?? 
                 reserva['sede']['name'] ?? 
                 reserva['sede']['title'] ?? 
                 'Sin sede';
        } else if (reserva['sede'] is String) {
          sede = reserva['sede'];
        }
      }
      
      if (conteo.containsKey(sede)) {
        conteo[sede] = conteo[sede]! + 1;
      } else {
        conteo[sede] = 1;
      }
    }
    
    return conteo;
  }

  // Colores vibrantes para cada barra
  List<Color> _getSedeColors() {
    return [
      const Color(0xFF0083B0), // Azul principal
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF43A047), // Verde
      const Color(0xFFFF6F00), // Naranja oscuro
      const Color(0xFF8E24AA), // Púrpura
      const Color(0xFFE91E63), // Rosa
      const Color(0xFF3F51B5), // Índigo
      const Color(0xFFFFC107), // Ámbar
      const Color(0xFF009688), // Teal
      const Color(0xFFD32F2F), // Rojo
    ];
  }

  String _abreviarNombreSede(String nombre) {
    // Si el nombre es muy largo, lo abrevia inteligentemente
    if (nombre.length <= 15) return nombre;
    
    // Buscar palabras clave para abreviar
    final palabras = nombre.split(' ');
    if (palabras.length > 1) {
      // Si tiene "Sede -", quitarlo
      if (palabras[0].toLowerCase() == 'sede' && palabras.length > 2) {
        return palabras.sublist(2).join(' ');
      }
      // Tomar las primeras letras de cada palabra importante
      return palabras.take(2).join(' ');
    }
    
    // Si es una sola palabra muy larga, truncar
    return '${nombre.substring(0, 12)}...';
  }

  Widget _buildGraficaReservasPorSede() {
    if (reservasRecientes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0083B0).withOpacity(0.1),
              const Color(0xFF00BCD4).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay datos para mostrar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las reservas aparecerán aquí',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final conteo = _contarReservasPorSede();
    if (conteo.isEmpty) return const SizedBox.shrink();
    
    final sedes = conteo.keys.toList();
    final cantidades = conteo.values.toList();
    final maxCantidad = cantidades.reduce((a, b) => a > b ? a : b);
    final totalReservas = cantidades.reduce((a, b) => a + b);
    final colores = _getSedeColors();
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con degradado
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0083B0),
                const Color(0xFF00BCD4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0083B0).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reservas por sede",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalReservas reservas en ${sedes.length} sede${sedes.length != 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Activo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Gráfica con diseño premium
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 280,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxCantidad.toDouble() + 2,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 12,
                        tooltipPadding: const EdgeInsets.all(12),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${sedes[group.x]}\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: '${rod.toY.toInt()} reserva${rod.toY.toInt() != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: screenWidth < 400 ? 35 : 45,
                          getTitlesWidget: (value, meta) {
                            if (value % 1 != 0) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: screenWidth < 400 ? 11 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        bottom: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      ),
                    ),
                    barGroups: List.generate(sedes.length, (index) {
                      final color = colores[index % colores.length];
                      final barWidth = screenWidth < 400 ? 25.0 : 35.0;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: cantidades[index].toDouble(),
                            gradient: LinearGradient(
                              colors: [
                                color,
                                color.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            width: barWidth,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxCantidad.toDouble() + 2,
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Leyenda con estadísticas (responsive)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(sedes.length, (index) {
                  final porcentaje = ((cantidades[index] / totalReservas) * 100).toStringAsFixed(1);
                  final color = colores[index % colores.length];
                  
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 400 ? 8 : 12,
                      vertical: screenWidth < 400 ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            sedes[index],
                            style: TextStyle(
                              fontSize: screenWidth < 400 ? 11 : 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${cantidades[index]} ($porcentaje%)',
                          style: TextStyle(
                            fontSize: screenWidth < 400 ? 10 : 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= BUILD =================

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
            _buildGraficaReservasPorSede(),
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
          icon: const Icon(Icons.people, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.superAdminUsuarios);
          },
          tooltip: 'Gestión de usuarios',
        ),
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
          label: const Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
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
    if (controller.customSedes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Canchas y sedes",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
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
                Text('No hay sedes creadas',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Presiona el botón "Crear sede" para agregar una',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87),
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
                  Text('No hay reservas aún', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
                onTap: () => _mostrarDetalleReserva(reservasRecientes[index], index),
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
          BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF0083B0),
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text("Andres Orellano", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Text(_elapsedText, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}