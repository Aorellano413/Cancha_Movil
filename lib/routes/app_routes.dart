import 'package:flutter/material.dart';
import '../vistas/login.dart';
import '../vistas/sedes.dart';
import '../vistas/inicio.dart';

class AppRoutes {
  static const login = '/login';
  static const sedes = '/sedes';
  static const inicio = '/inicio';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      sedes: (context) => const SedesPage(),
      inicio: (context) => const InicioPage(),
    };
  }
}
