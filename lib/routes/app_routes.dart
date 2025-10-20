// lib/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/sedes_view.dart';
import '../views/reserva_view.dart';
import '../views/pagos_view.dart';
import '../views/login_admin_view.dart';
import '../views/admin_dashboard_view.dart';
import '../views/super_admin_usuarios_view.dart';
import '../views/propietario_dashboard_view.dart';
import '../views/propietario_canchas_view.dart';

class AppRoutes {
  // Rutas públicas
  static const String login = '/login';
  static const String sedes = '/sedes';
  static const String reserva = '/reserva';
  static const String pagos = '/pagos';
  
  // Rutas de administración
  static const String loginAdmin = '/loginAdmin';
  static const String adminDashboard = '/adminDashboard';
  static const String superAdminUsuarios = '/superAdminUsuarios';
  
  // Rutas de propietario
  static const String propietarioDashboard = '/propietarioDashboard';
  static const String propietarioCanchas = '/propietarioCanchas';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    sedes: (context) => const SedesView(),
    reserva: (context) => const ReservaView(),
    pagos: (context) => const PagosView(),
    loginAdmin: (context) => const LoginAdminView(),
    adminDashboard: (context) => const AdminDashboardView(),
    superAdminUsuarios: (context) => const SuperAdminUsuariosView(),
    propietarioDashboard: (context) => const PropietarioDashboardView(),
    propietarioCanchas: (context) => const PropietarioCanchasView(),
  };
  
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case sedes:
        return MaterialPageRoute(builder: (_) => const SedesView());
      case reserva:
        return MaterialPageRoute(builder: (_) => const ReservaView());
      case pagos:
        return MaterialPageRoute(builder: (_) => const PagosView());
      case loginAdmin:
        return MaterialPageRoute(builder: (_) => const LoginAdminView());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardView());
      case superAdminUsuarios:
        return MaterialPageRoute(builder: (_) => const SuperAdminUsuariosView());
      case propietarioDashboard:
        return MaterialPageRoute(builder: (_) => const PropietarioDashboardView());
      case propietarioCanchas:
        return MaterialPageRoute(builder: (_) => const PropietarioCanchasView());
      default:
        return null;
    }
  }
}