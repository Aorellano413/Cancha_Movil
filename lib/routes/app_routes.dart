import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/sedes_view.dart';
import '../views/reserva_view.dart';
import '../views/pagos_view.dart';
import '../views/login_admin_view.dart';
import '../views/admin_dashboard_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String sedes = '/sedes';
  static const String reserva = '/reserva';
  static const String pagos = '/pagos';
  static const String loginAdmin = '/loginAdmin';
  static const String adminDashboard = '/adminDashboard';
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    sedes: (context) => const SedesView(),
    
    reserva: (context) => const ReservaView(),
    pagos: (context) => const PagosView(),
    loginAdmin: (context) => const LoginAdminView(),
    adminDashboard: (context) => const AdminDashboardView(),
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
      default:
        return null;
    }
  }
}
