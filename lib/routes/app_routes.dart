// routes/app_routes.dart
import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/sedes_view.dart';
import '../views/inicio_view.dart';
import '../views/reserva_view.dart';
import '../views/pagos_view.dart'; 

class AppRoutes {
  static const String login = '/login';
  static const String sedes = '/sedes';
  static const String inicio = '/inicio';
  static const String reserva = '/reserva';
  static const String pagos = '/pagos'; 

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    sedes: (context) => const SedesView(),
    inicio: (context) => const InicioView(),
    reserva: (context) => const ReservaView(),
    pagos: (context) => const PagosView()
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case sedes:
        return MaterialPageRoute(builder: (_) => const SedesView());
      case inicio:
        return MaterialPageRoute(builder: (_) => const InicioView());
      case reserva:
        return MaterialPageRoute(builder: (_) => const ReservaView());
      case pagos:
        return MaterialPageRoute(builder: (_) => const PagosView());
      default:
        return null;
    }
  }
}
