import 'package:flutter/material.dart';
import '../vistas/login.dart';
import '../vistas/Sedes.dart';
import '../vistas/inicio.dart';


class AppRoutes {
  static const String login = '/login';
  static const String sedes = '/sedes';
  static const String inicio = '/inicio';
  static const String reserva = '/reserva';
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    sedes: (context) => const SedesScreen(),
    inicio: (context) => const InicioScreen(),
  };
}
