// lib/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;
  bool get isPropietario => _currentUser?.isPropietario ?? false;

  AuthController() {
    _initAuthListener();
  }

  /// cambios en el estado de autenticación
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Cargar datos del usuario desde Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _currentUser = await _authService.getUserData(uid);
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar datos del usuario: $e';
      notifyListeners();
    }
  }

  /// Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultado = await _authService.login(
        email: email,
        password: password,
      );

      if (resultado['success']) {
        _currentUser = resultado['user'];
      } else {
        _error = resultado['message'];
      }

      _isLoading = false;
      notifyListeners();

      return resultado;
    } catch (e) {
      _error = 'Error inesperado: $e';
      _isLoading = false;
      notifyListeners();

      return {
        'success': false,
        'message': _error,
      };
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Recargar datos del usuario actual
  Future<void> reloadUserData() async {
    if (_authService.currentUser != null) {
      await _loadUserData(_authService.currentUser!.uid);
    }
  }

  /// Cambiar contraseña
  Future<Map<String, dynamic>> cambiarPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final resultado = await _authService.cambiarPassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    _isLoading = false;
    notifyListeners();

    return resultado;
  }

  /// Recuperar contraseña
  Future<Map<String, dynamic>> recuperarPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    final resultado = await _authService.recuperarPassword(email);

    _isLoading = false;
    notifyListeners();

    return resultado;
  }
}