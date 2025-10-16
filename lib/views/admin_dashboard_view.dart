// lib/views/admin_dashboard_view.dart
import 'dart:async';
import 'dart:ui';
import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/sedes_controller.dart';
import '../models/sede_model.dart';
import '../routes/app_routes.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

enum ReservaEstado { pendiente, pagado, cancelado }

extension ReservaEstadoX on ReservaEstado {
  String get label {
    switch (this) {
      case ReservaEstado.pendiente:
        return 'Pendiente';
      case ReservaEstado.pagado:
        return 'Pagado';
      case ReservaEstado.cancelado:
        return 'Cancelado';
    }
  }

  Color get color {
    switch (this) {
      case ReservaEstado.pendiente:
        return const Color(0xFFFFA000); 
      case ReservaEstado.pagado:
        return const Color(0xFF2E7D32); 
      case ReservaEstado.cancelado:
        return const Color(0xFFC62828); 
    }
  }
}

class Reserva {
  final String nombre;
  final String sede;
  final String inicio;
  final String fin;
  final String correo;
  final String telefono;
  final String cancha; 
  final String monto;  
  ReservaEstado estado;

  Reserva({
    required this.nombre,
    required this.sede,
    required this.inicio,
    required this.fin,
    required this.correo,
    required this.telefono,
    required this.cancha,
    required this.monto,
    this.estado = ReservaEstado.pendiente,
  });
}
/* ============================================================= */

class _AdminDashboardViewState extends State<AdminDashboardView> {
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _elapsedText = "00:00";
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String _pickedPath = '';
  int? _editingCustomIndex;

  final List<Map<String, dynamic>> sedesDemo = [
    {
      'nombre': 'La Jugada Principal',
      'color': const Color(0xFF0083B0),
      'reservas': 1,
      'image': 'lib/images/jugada.jpg'
    },
    {
      'nombre': 'La Jugada Secundaria',
      'color': const Color(0xFF00B4DB),
      'reservas': 1,
      'image': 'lib/images/sede2.jpg'
    },
    {
      'nombre': 'Biblos',
      'color': const Color(0xFF2E8B57),
      'reservas': 2,
      'image': 'lib/images/biblos.jpg'
    },
    {
      'nombre': 'El Fortín',
      'color': const Color(0xFFE07B39),
      'reservas': 1,
      'image': 'lib/images/fortin.jpg'
    },
  ];

  late List<Reserva> reservasRecientes;

  @override
  void initState() {
    super.initState();

    reservasRecientes = [
      Reserva(
        nombre: 'Adel Andrés Orellano',
        sede: 'La Jugada Principal',
        inicio: '17:00',
        fin: '18:00',
        correo: 'andresorellano591@gmail.com',
        telefono: '3003525431',
        cancha: 'Cancha techada',
        monto: '\$80000',
        estado: ReservaEstado.pendiente,
      ),
      Reserva(
        nombre: 'Carlos Ruiz',
        sede: 'Biblos',
        inicio: '14:00',
        fin: '15:00',
        correo: 'carlos.ruiz@mail.com',
        telefono: '3002223344',
        cancha: 'Cancha descubierta',
        monto: '\$60000',
        estado: ReservaEstado.pendiente,
      ),
      Reserva(
        nombre: 'Sofía Ramírez',
        sede: 'El Fortín',
        inicio: '18:00',
        fin: '19:00',
        correo: 'sofia.ramirez@mail.com',
        telefono: '3003334455',
        cancha: 'Cancha techada',
        monto: '\$80000',
        estado: ReservaEstado.pendiente,
      ),
      Reserva(
        nombre: 'Luis Fernández',
        sede: 'La Jugada Secundaria',
        inicio: '10:00',
        fin: '11:00',
        correo: 'luis.fernandez@mail.com',
        telefono: '3004445566',
        cancha: 'Cancha 7',
        monto: '\$50000',
        estado: ReservaEstado.pendiente,
      ),
      Reserva(
        nombre: 'Marta Silva',
        sede: 'Biblos',
        inicio: '12:00',
        fin: '13:00',
        correo: 'marta.silva@mail.com',
        telefono: '3005556677',
        cancha: 'Cancha 5',
        monto: '\$50000',
        estado: ReservaEstado.pendiente,
      ),
    ];

    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final d = _stopwatch.elapsed;
      final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      setState(() => _elapsedText = "$mm:$ss");
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  ImageProvider _providerFromPath(String path) {
    if (kIsWeb && (path.startsWith('blob:') || path.startsWith('http'))) {
      return NetworkImage(path);
    } else if (path.startsWith('/') || path.contains(':\\')) {
      return FileImage(File(path));
    } else {
      return AssetImage(path);
    }
  }

  String _formatCOP(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '\$0';
    final sb = StringBuffer();
    final chars = digits.split('').reversed.toList();
    for (int i = 0; i < chars.length; i++) {
      if (i != 0 && i % 3 == 0) sb.write('.');
      sb.write(chars[i]);
    }
    final withDots = sb.toString().split('').reversed.join();
    return '\$$withDots';
  }

  Future<void> _pickImage() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _pickedPath = x.path);
  }

  // ====== UI: Tarjeta de sede demo ======
  Widget _demoCard(Map<String, dynamic> s) {
    final reservas = (s['reservas'] is int)
        ? (s['reservas'] as int)
        : (s['reservas'] is List ? (s['reservas'] as List).length : 0);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
        image: DecorationImage(
          image: AssetImage(s['image']),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(s['color'].withOpacity(0.55), BlendMode.darken),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), child: const SizedBox.shrink())),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s['nombre'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          const Icon(Icons.event_available, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text("$reservas", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(alignment: Alignment.bottomRight, child: Icon(Icons.sports_soccer, color: Colors.white.withOpacity(0.9), size: 28)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customCard(SedeModel s, int customIndex) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
        image: DecorationImage(
          image: _providerFromPath(s.imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(const Color(0xFF0083B0).withOpacity(0.35), BlendMode.darken),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), child: const SizedBox.shrink())),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(12)),
                child: const Text('Día - Noche', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9)),
                    onPressed: () => _openSheet(editCustomIndex: customIndex, seed: s),
                    icon: const Icon(Icons.edit, size: 18),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9)),
                    onPressed: () => _confirmDelete(customIndex),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reservaItem(Reserva r, int index) {
    final inicial = (r.nombre.isNotEmpty ? r.nombre.trim()[0] : '?').toUpperCase();

    return InkWell(
      onTap: () => _showReservaDetalle(r, index),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 0.8,
        color: const Color(0xFFF0F3F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0083B0),
                child: Text(inicial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(r.nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: r.estado.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: r.estado.color.withOpacity(0.5)),
                          ),
                          child: Text(
                            r.estado.label,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: r.estado.color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${r.sede} • ${r.inicio} – ${r.fin}', style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showReservaDetalle(Reserva r, int index) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFEAEFF3), // gris claro similar al ejemplo
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        Widget rowIconText(IconData icon, String text) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0083B0)),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 38, height: 5, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),

              const Text(
                'Detalles de la Reserva',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              rowIconText(Icons.person_pin_circle_outlined, 'Nombre: ${r.nombre}'),
              rowIconText(Icons.alternate_email, 'Correo: ${r.correo}'),
              rowIconText(Icons.phone_android, 'Teléfono: ${r.telefono}'),
              rowIconText(Icons.place_outlined, 'Sede: ${r.sede}'),
              rowIconText(Icons.access_time_filled_outlined, 'Hora: ${r.inicio} – ${r.fin}'),
              rowIconText(Icons.sports_soccer_outlined, 'Cancha: ${r.cancha}'),
              rowIconText(Icons.attach_money, 'Monto: ${r.monto}'),

              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  children: [
                    const TextSpan(text: 'Estado actual: ', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: r.estado.label, style: TextStyle(fontWeight: FontWeight.w700, color: r.estado.color)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Marcar como Pagado'),
                      onPressed: () {
                        setState(() => reservasRecientes[index].estado = ReservaEstado.pagado);
                        Navigator.pop(ctx);
                        _snack('Reserva marcada como PAGADO');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Marcar como Cancelado'),
                      onPressed: () {
                        setState(() => reservasRecientes[index].estado = ReservaEstado.cancelado);
                        Navigator.pop(ctx);
                        _snack('Reserva CANCELADA');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFC62828),
                        side: const BorderSide(color: Color(0xFFC62828)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSheet({int? editCustomIndex, SedeModel? seed}) {
    final isEdit = editCustomIndex != null && seed != null;

    _formKey.currentState?.reset();
    if (isEdit) {
      _nombreCtrl.text = seed.title.replaceFirst('Sede - ', '');
      _direccionCtrl.text = seed.subtitle;
      _precioCtrl.text = seed.price.replaceAll(RegExp(r'[^0-9]'), '');
      _pickedPath = seed.imagePath;
    } else {
      _nombreCtrl.clear();
      _direccionCtrl.clear();
      _precioCtrl.clear();
      _pickedPath = '';
    }
    _editingCustomIndex = editCustomIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)))),
                const SizedBox(height: 12),
                Text(isEdit ? 'Editar sede' : 'Crear nueva sede', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),

                // previsualización
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFF2F4F7),
                      border: Border.all(color: const Color(0xFFE0E3E7)),
                      image: _pickedPath.isEmpty ? null : DecorationImage(image: _providerFromPath(_pickedPath), fit: BoxFit.cover),
                    ),
                    child: _pickedPath.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, size: 30, color: Colors.black54),
                                SizedBox(height: 8),
                                Text('Subir imagen de la sede', style: TextStyle(color: Colors.black54)),
                              ],
                            ),
                          )
                        : Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(12)),
                              child: const Text('Imagen seleccionada', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 12),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre de la sede', prefixIcon: Icon(Icons.home_outlined), border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _direccionCtrl,
                  decoration: const InputDecoration(labelText: 'Dirección', prefixIcon: Icon(Icons.place_outlined), border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa una dirección' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _precioCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Precio desde (COP, ej: 90000)', prefixIcon: Icon(Icons.attach_money), border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un precio' : null,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('Día - Noche')),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(isEdit ? Icons.save_outlined : Icons.check_circle_outline),
                    label: Text(isEdit ? 'Guardar cambios' : 'Crear sede'),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      if (_pickedPath.isEmpty) {
                        _snack('Selecciona una imagen');
                        return;
                      }
                      final formatted = _formatCOP(_precioCtrl.text);
                      final model = SedeModel(
                        imagePath: _pickedPath,
                        title: "Sede - ${_nombreCtrl.text.trim()}",
                        subtitle: _direccionCtrl.text.trim(),
                        price: formatted,
                        tag: 'Día - Noche',
                        isCustom: true,
                      );

                      final c = Provider.of<SedesController>(context, listen: false);
                      if (isEdit) {
                        c.actualizarSedeCustom(_editingCustomIndex!, model);
                        Navigator.pop(ctx);
                        _snack('Sede actualizada');
                      } else {
                        c.agregarSede(model);
                        Navigator.pop(ctx);
                        _snack('Sede creada');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(int customIndex) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar sede'),
        content: const Text('¿Seguro que quieres eliminar esta sede?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      Provider.of<SedesController>(context, listen: false).eliminarSedeCustom(customIndex);
      _snack('Sede eliminada');
    }
  }

  @override
  Widget build(BuildContext context) {
    final custom = context.watch<SedesController>().customSedes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0083B0),
        elevation: 0,
        titleSpacing: 0,
        title: const Text("Panel Administrativo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.white), label: const Text("Cerrar sesión", style: TextStyle(color: Colors.white))),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Canchas y reservas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),

          // Carrusel de sedes
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 12),
              itemCount: sedesDemo.length + custom.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return SizedBox(
                    width: 240,
                    child: OutlinedButton.icon(
                      onPressed: () => _openSheet(),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear sede'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                    ),
                  );
                }
                final idx = i - 1;
                if (idx < sedesDemo.length) {
                  return _demoCard(sedesDemo[idx]);
                } else {
                  final cIdx = idx - sedesDemo.length;
                  return _customCard(custom[cIdx], cIdx);
                }
              },
            ),
          ),

          const SizedBox(height: 20),
          const Text("Reservas recientes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
          const SizedBox(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reservasRecientes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, i) => _reservaItem(reservasRecientes[i], i),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, -2))]),
        child: Row(
          children: [
            const CircleAvatar(radius: 18, backgroundColor: Color(0xFF0083B0), child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            const Expanded(child: Text("Admin Andrés Orellano", style: TextStyle(fontWeight: FontWeight.w600))),
            const Icon(Icons.timer_outlined, size: 18, color: Colors.black54),
            const SizedBox(width: 6),
            Text(_elapsedText, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Crear sede'),
      ),
    );
  }
}
