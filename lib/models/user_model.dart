// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  superAdmin,
  propietario,
}

class UserModel {
  final String? id; // UID de Firebase Auth
  final String nombre;
  final String email;
  final UserRole rol;
  final String? sedeAsignada; // Solo para propietarios
  final String? telefono;
  final DateTime? createdAt;
  final bool activo;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.sedeAsignada,
    this.telefono,
    this.createdAt,
    this.activo = true,
  });

  // Convertir desde JSON de Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: _parseRole(json['rol']),
      sedeAsignada: json['sedeAsignada'],
      telefono: json['telefono'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      activo: json['activo'] ?? true,
    );
  }

  // Convertir a JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol.name,
      if (sedeAsignada != null) 'sedeAsignada': sedeAsignada,
      if (telefono != null) 'telefono': telefono,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'activo': activo,
    };
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'superadmin':
      case 'super_admin':
        return UserRole.superAdmin;
      case 'propietario':
        return UserRole.propietario;
      default:
        return UserRole.propietario;
    }
  }

  // Helper para verificar si es super admin
  bool get isSuperAdmin => rol == UserRole.superAdmin;

  // Helper para verificar si es propietario
  bool get isPropietario => rol == UserRole.propietario;

  // Copiar con modificaciones
  UserModel copyWith({
    String? id,
    String? nombre,
    String? email,
    UserRole? rol,
    String? sedeAsignada,
    String? telefono,
    DateTime? createdAt,
    bool? activo,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      sedeAsignada: sedeAsignada ?? this.sedeAsignada,
      telefono: telefono ?? this.telefono,
      createdAt: createdAt ?? this.createdAt,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, nombre: $nombre, email: $email, rol: ${rol.name})';
  }
}