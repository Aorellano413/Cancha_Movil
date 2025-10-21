// lib/widgets/sede_form_sheet.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/sedes_controller.dart';
import '../models/sede_model.dart';
import '../utils/formato_helpers.dart';
import '../services/storage_service.dart';

class SedeFormSheet extends StatefulWidget {
  final SedeModel? sedeParaEditar;
  final int? editIndex;
  final Function(String mensaje) onGuardado;

  const SedeFormSheet({
    super.key,
    this.sedeParaEditar,
    this.editIndex,
    required this.onGuardado,
  });

  @override
  State<SedeFormSheet> createState() => _SedeFormSheetState();
}

class _SedeFormSheetState extends State<SedeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String _pickedPath = '';
  XFile? _pickedImage;
  bool _isUploading = false;

  bool get _esEdicion => widget.sedeParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreCtrl.text = widget.sedeParaEditar!.title.replaceFirst('Sede - ', '');
      _direccionCtrl.text = widget.sedeParaEditar!.subtitle;
      _precioCtrl.text = widget.sedeParaEditar!.price.replaceAll(RegExp(r'[^0-9]'), '');
      _pickedPath = widget.sedeParaEditar!.imagePath;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final imagen = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (imagen != null) {
      setState(() {
        _pickedPath = imagen.path;
        _pickedImage = imagen;
      });
    }
  }

  // ✅ MÉTODO CORREGIDO: Mostrar preview según tipo de imagen
  Widget _buildImagePreview() {
    if (_pickedPath.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 30,
              color: Colors.black54,
            ),
            SizedBox(height: 8),
            Text(
              'Subir imagen de la sede',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }

    // Si hay una imagen nueva seleccionada (blob en web o path en móvil)
    if (_pickedImage != null) {
      if (kIsWeb) {
        // En web, usar Image.network con la URL blob
        return Image.network(
          _pickedPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.error, size: 64, color: Colors.red),
            );
          },
        );
      } else {
        // En móvil, usar Image.file
        return Image.file(
          File(_pickedPath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade300,
              child: const Icon(Icons.error, size: 64, color: Colors.red),
            );
          },
        );
      }
    }

    // Si es una URL de Firebase (ya guardada)
    if (_pickedPath.startsWith('http://') || _pickedPath.startsWith('https://')) {
      return Image.network(
        _pickedPath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.error, size: 64, color: Colors.red),
          );
        },
      );
    }

    // Si es un asset local
    return Image.asset(
      _pickedPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.error, size: 64, color: Colors.red),
        );
      },
    );
  }

  Future<void> _guardarSede() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedPath.isEmpty) {
      _mostrarError('Selecciona una imagen para la sede');
      return;
    }

    if (_pickedImage == null && !_esEdicion) {
      _mostrarError('Debe seleccionar una imagen nueva');
      return;
    }

    setState(() => _isUploading = true);

    final controller = Provider.of<SedesController>(context, listen: false);
    final storageService = StorageService();

    try {
      String imageUrl = _pickedPath;

      final necesitaSubir = _pickedImage != null || 
                            !storageService.esUrlFirebase(_pickedPath);

      if (necesitaSubir) {
        if (_pickedImage == null) {
          _mostrarError('Debe seleccionar una imagen válida');
          setState(() => _isUploading = false);
          return;
        }

        final sedeId = _esEdicion && widget.sedeParaEditar!.id != null
            ? widget.sedeParaEditar!.id!
            : DateTime.now().millisecondsSinceEpoch.toString();

        print('📤 Subiendo imagen a Firebase Storage...');

        imageUrl = await storageService.subirImagenSede(
          sedeId: sedeId,
          imageFile: _pickedImage!,
        );

        print('✅ Imagen subida exitosamente: $imageUrl');

        if (_esEdicion &&
            widget.sedeParaEditar!.imagePath.isNotEmpty &&
            storageService.esUrlFirebase(widget.sedeParaEditar!.imagePath)) {
          print('🗑️ Eliminando imagen anterior...');
          await storageService.eliminarImagen(widget.sedeParaEditar!.imagePath);
        }
      }

      final precioFormateado = FormatoHelpers.formatearCOP(_precioCtrl.text);
      final sedeModel = SedeModel(
        imagePath: imageUrl,
        title: "Sede - ${_nombreCtrl.text.trim()}",
        subtitle: _direccionCtrl.text.trim(),
        price: precioFormateado,
        tag: 'Día - Noche',
        isCustom: true,
      );

      print('💾 Guardando en Firestore: ${sedeModel.toJson()}');

      if (_esEdicion && widget.editIndex != null) {
        await controller.actualizarSedeCustom(widget.editIndex!, sedeModel);
        if (mounted) {
          Navigator.pop(context);
          widget.onGuardado('Sede actualizada exitosamente');
        }
      } else {
        await controller.agregarSede(sedeModel);
        if (mounted) {
          Navigator.pop(context);
          widget.onGuardado('Sede creada exitosamente');
        }
      }
    } catch (e) {
      print('❌ Error al guardar: $e');
      _mostrarError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _esEdicion ? 'Editar sede' : 'Crear nueva sede',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFF2F4F7),
                  border: Border.all(color: const Color(0xFFE0E3E7)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImagePreview(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la sede',
                prefixIcon: Icon(Icons.home_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                prefixIcon: Icon(Icons.place_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa una dirección'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _precioCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio desde (COP, ej: 90000)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa un precio' : null,
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
                icon: Icon(
                  _esEdicion ? Icons.save_outlined : Icons.check_circle_outline,
                ),
                label: Text(_isUploading
                    ? 'Subiendo imagen...'
                    : (_esEdicion ? 'Guardar cambios' : 'Crear sede')),
                onPressed: _isUploading ? null : _guardarSede,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0083B0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}