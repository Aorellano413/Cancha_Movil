// lib/views/super_admin_usuarios_view.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/sede_model.dart';

class SuperAdminUsuariosView extends StatefulWidget {
  const SuperAdminUsuariosView({super.key});

  @override
  State<SuperAdminUsuariosView> createState() => _SuperAdminUsuariosViewState();
}

class _SuperAdminUsuariosViewState extends State<SuperAdminUsuariosView> {
  final AuthService _authService = AuthService();
  List<UserModel> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    _usuarios = await _authService.getAllUsers();
    setState(() => _isLoading = false);
  }

  void _mostrarFormulario({UserModel? usuario}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FormularioUsuario(
        usuario: usuario,
        onGuardado: () {
          _cargarUsuarios();
          Navigator.pop(ctx);
          _mostrarSnackbar(
            usuario == null ? 'Usuario creado' : 'Usuario actualizado',
          );
        },
      ),
    );
  }

  Future<void> _confirmarEliminar(UserModel usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Desactivar a ${usuario.nombre}?'),
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

    if (confirmar == true && usuario.id != null) {
      final resultado = await _authService.eliminarUsuario(usuario.id!);
      
      if (mounted) {
        _mostrarSnackbar(resultado['message']);
        if (resultado['success']) {
          _cargarUsuarios();
        }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: const Color(0xFF0083B0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No hay usuarios registrados',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarUsuarios,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _usuarios.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final usuario = _usuarios[index];
                      return _UsuarioCard(
                        usuario: usuario,
                        onEditar: () => _mostrarFormulario(usuario: usuario),
                        onEliminar: () => _confirmarEliminar(usuario),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        icon: const Icon(Icons.person_add),
        label: const Text('Crear Usuario'),
        backgroundColor: const Color(0xFF0083B0),
      ),
    );
  }
}

// ============ CARD DE USUARIO ============
class _UsuarioCard extends StatelessWidget {
  final UserModel usuario;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _UsuarioCard({
    required this.usuario,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final Color roleColor = usuario.isSuperAdmin 
        ? const Color(0xFF2E7D32) 
        : const Color(0xFF0083B0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: roleColor.withOpacity(0.1),
              child: Icon(
                usuario.isSuperAdmin ? Icons.admin_panel_settings : Icons.store,
                color: roleColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          usuario.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          usuario.isSuperAdmin ? 'Super Admin' : 'Propietario',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (usuario.telefono != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      usuario.telefono!,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                  if (!usuario.activo) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'INACTIVO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'editar') {
                  onEditar();
                } else if (value == 'eliminar') {
                  onEliminar();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============ FORMULARIO DE USUARIO ============
class _FormularioUsuario extends StatefulWidget {
  final UserModel? usuario;
  final VoidCallback onGuardado;

  const _FormularioUsuario({
    this.usuario,
    required this.onGuardado,
  });

  @override
  State<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<_FormularioUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  
  UserRole _rolSeleccionado = UserRole.propietario;
  String? _sedeSeleccionada;
  List<SedeModel> _sedes = [];
  bool _isLoading = false;
  bool _showPassword = false;

  bool get _esEdicion => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _cargarSedes();
    
    if (_esEdicion) {
      _nombreCtrl.text = widget.usuario!.nombre;
      _emailCtrl.text = widget.usuario!.email;
      _telefonoCtrl.text = widget.usuario!.telefono ?? '';
      _rolSeleccionado = widget.usuario!.rol;
      _sedeSeleccionada = widget.usuario!.sedeAsignada;
    }
  }

  Future<void> _cargarSedes() async {
    _sedes = await FirestoreService().getSedes();
    setState(() {});
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar sede para propietarios
    if (_rolSeleccionado == UserRole.propietario && _sedeSeleccionada == null) {
      _mostrarError('Debe seleccionar una sede para el propietario');
      return;
    }

    // Validar contraseña si es creación
    if (!_esEdicion && _passwordCtrl.text.trim().isEmpty) {
      _mostrarError('La contraseña es obligatoria');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_esEdicion) {
        // Actualizar usuario existente
        final usuarioActualizado = widget.usuario!.copyWith(
          nombre: _nombreCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim().isEmpty 
              ? null 
              : _telefonoCtrl.text.trim(),
          rol: _rolSeleccionado,
          sedeAsignada: _rolSeleccionado == UserRole.propietario 
              ? _sedeSeleccionada 
              : null,
        );

        final resultado = await AuthService().actualizarUsuario(
          uid: widget.usuario!.id!,
          userData: usuarioActualizado,
        );

        if (mounted) {
          if (resultado['success']) {
            widget.onGuardado();
          } else {
            _mostrarError(resultado['message']);
          }
        }
      } else {
        // Crear nuevo usuario
        final resultado = await AuthService().crearUsuario(
          nombre: _nombreCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          rol: _rolSeleccionado,
          sedeAsignada: _rolSeleccionado == UserRole.propietario 
              ? _sedeSeleccionada 
              : null,
          telefono: _telefonoCtrl.text.trim().isEmpty 
              ? null 
              : _telefonoCtrl.text.trim(),
        );

        if (mounted) {
          if (resultado['success']) {
            widget.onGuardado();
          } else {
            _mostrarError(resultado['message']);
          }
        }
      }
    } catch (e) {
      _mostrarError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            const SizedBox(height: 16),
            Text(
              _esEdicion ? 'Editar Usuario' : 'Crear Usuario',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Nombre
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.trim().isEmpty ?? true 
                  ? 'Ingrese el nombre' 
                  : null,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailCtrl,
              enabled: !_esEdicion, // No editable en modo edición
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
                helperText: _esEdicion ? 'El email no se puede modificar' : null,
              ),
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Ingrese el email';
                if (!v!.contains('@')) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contraseña (solo en creación)
            if (!_esEdicion) ...[
              TextFormField(
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  helperText: 'Mínimo 6 caracteres',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return 'Ingrese la contraseña';
                  if (v!.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // Teléfono
            TextFormField(
              controller: _telefonoCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Rol
            DropdownButtonFormField<UserRole>(
              value: _rolSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Rol',
                prefixIcon: Icon(Icons.admin_panel_settings),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: UserRole.superAdmin,
                  child: Text('Super Administrador'),
                ),
                DropdownMenuItem(
                  value: UserRole.propietario,
                  child: Text('Propietario de Sede'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _rolSeleccionado = value!;
                  if (_rolSeleccionado == UserRole.superAdmin) {
                    _sedeSeleccionada = null;
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Sede (solo para propietarios)
            if (_rolSeleccionado == UserRole.propietario) ...[
              DropdownButtonFormField<String>(
                value: _sedeSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Sede asignada *',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                ),
                items: _sedes.map((sede) {
                  return DropdownMenuItem(
                    value: sede.id,
                    child: Text(sede.title),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _sedeSeleccionada = value),
                validator: (v) => v == null 
                    ? 'Seleccione una sede' 
                    : null,
              ),
              const SizedBox(height: 16),
            ],

            // Botón guardar
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0083B0),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_esEdicion ? 'Actualizar' : 'Crear Usuario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}