// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        return {
          'success': false,
          'message': 'Error al iniciar sesión',
        };
      }

      final userData = await getUserData(credential.user!.uid);
      
      if (userData == null) {
        await logout();
        return {
          'success': false,
          'message': 'Usuario no encontrado en la base de datos',
        };
      }

      if (!userData.activo) {
        await logout();
        return {
          'success': false,
          'message': 'Usuario inactivo. Contacte al administrador',
        };
      }

      return {
        'success': true,
        'message': 'Bienvenido ${userData.nombre}',
        'user': userData,
      };
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al iniciar sesión';
      
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'Usuario no encontrado';
          break;
        case 'wrong-password':
          mensaje = 'Contraseña incorrecta';
          break;
        case 'invalid-email':
          mensaje = 'Email inválido';
          break;
        case 'user-disabled':
          mensaje = 'Usuario deshabilitado';
          break;
        case 'too-many-requests':
          mensaje = 'Demasiados intentos. Intente más tarde';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }

      return {
        'success': false,
        'message': mensaje,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  bool get isAuthenticated => currentUser != null;

  Future<Map<String, dynamic>> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required UserRole rol,
    String? sedeAsignada,
    String? telefono,
  }) async {

    final adminActual = currentUser;
    final adminEmail = adminActual?.email;
    
    if (adminActual == null || adminEmail == null) {
      return {
        'success': false,
        'message': 'No hay sesión de administrador activa',
      };
    }

    try {
      final currentUserData = await getUserData(adminActual.uid);
      if (currentUserData == null || !currentUserData.isSuperAdmin) {
        return {
          'success': false,
          'message': 'No tiene permisos para crear usuarios',
        };
      }

      if (rol == UserRole.propietario && sedeAsignada == null) {
        return {
          'success': false,
          'message': 'Los propietarios deben tener una sede asignada',
        };
      }

      final secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      try {
        final credential = await secondaryAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        if (credential.user == null) {
          await secondaryApp.delete();
          return {
            'success': false,
            'message': 'Error al crear usuario en Firebase Auth',
          };
        }

        final uid = credential.user!.uid;

        final nuevoUsuario = UserModel(
          id: uid,
          nombre: nombre.trim(),
          email: email.trim(),
          rol: rol,
          sedeAsignada: rol == UserRole.propietario ? sedeAsignada : null,
          telefono: telefono?.trim(),
          createdAt: DateTime.now(),
          activo: true,
        );

        await _firestore
            .collection('usuarios')
            .doc(uid)
            .set(nuevoUsuario.toJson());

        if (rol == UserRole.propietario && sedeAsignada != null) {
          await _firestore.collection('sedes').doc(sedeAsignada).update({
            'propietarioId': uid,
            'contactoPropietario': telefono ?? '',
          });
        }

        await secondaryAuth.signOut();
        await secondaryApp.delete();

        return {
          'success': true,
          'message': 'Usuario creado exitosamente',
          'uid': uid,
        };
      } catch (e) {

        await secondaryApp.delete();
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al crear usuario';
      
      switch (e.code) {
        case 'email-already-in-use':
          mensaje = 'Este email ya está registrado';
          break;
        case 'invalid-email':
          mensaje = 'Email inválido';
          break;
        case 'weak-password':
          mensaje = 'La contraseña debe tener al menos 6 caracteres';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }

      return {
        'success': false,
        'message': mensaje,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('usuarios').get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return UserModel.fromJson(data);
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> actualizarUsuario({
    required String uid,
    required UserModel userData,
  }) async {
    try {

      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData == null || !currentUserData.isSuperAdmin) {
        return {
          'success': false,
          'message': 'No tiene permisos para actualizar usuarios',
        };
      }

      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update(userData.toJson());

      if (userData.isPropietario && userData.sedeAsignada != null) {
        await _firestore
            .collection('sedes')
            .doc(userData.sedeAsignada!)
            .update({
          'propietarioId': uid,
          'contactoPropietario': userData.telefono ?? '',
        });
      }

      return {
        'success': true,
        'message': 'Usuario actualizado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al actualizar usuario: $e',
      };
    }
  }

  Future<Map<String, dynamic>> eliminarUsuario(String uid) async {
    try {

      final currentUserData = await getUserData(currentUser?.uid ?? '');
      if (currentUserData == null || !currentUserData.isSuperAdmin) {
        return {
          'success': false,
          'message': 'No tiene permisos para eliminar usuarios',
        };
      }

      if (uid == currentUser?.uid) {
        return {
          'success': false,
          'message': 'No puede eliminarse a sí mismo',
        };
      }

      await _firestore.collection('usuarios').doc(uid).update({
        'activo': false,
      });

      return {
        'success': true,
        'message': 'Usuario desactivado exitosamente',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al eliminar usuario: $e',
      };
    }
  }

  Future<Map<String, dynamic>> cambiarPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No hay usuario autenticado',
        };
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      // Cambiar contraseña
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Contraseña actualizada exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al cambiar contraseña';
      
      switch (e.code) {
        case 'wrong-password':
          mensaje = 'Contraseña actual incorrecta';
          break;
        case 'weak-password':
          mensaje = 'La nueva contraseña debe tener al menos 6 caracteres';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }

      return {
        'success': false,
        'message': mensaje,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  Future<Map<String, dynamic>> recuperarPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      return {
        'success': true,
        'message': 'Se ha enviado un correo para restablecer tu contraseña',
      };
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al enviar correo';
      
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'No existe un usuario con ese email';
          break;
        case 'invalid-email':
          mensaje = 'Email inválido';
          break;
        default:
          mensaje = 'Error: ${e.message}';
      }

      return {
        'success': false,
        'message': mensaje,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }
}