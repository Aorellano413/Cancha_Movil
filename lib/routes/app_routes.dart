import 'package:flutter/material.dart';
import '../views/login_view.dart';
import '../views/sedes_view.dart';
import '../views/inicioj_view.dart';
import '../views/inicioj2_view.dart'; 
import '../views/iniciob_view.dart';
import '../views/iniciof_view.dart';
import '../views/reserva_view.dart';
import '../views/pagos_view.dart';

class AppRoutes {
  static const String login = '/login';
  static const String sedes = '/sedes';
  static const String inicioJugada = '/inicioj';
  static const String inicioJugada2 = '/inicioj2'; 
  static const String inicioBiblos = '/iniciob';
  static const String inicioFortin = '/iniciof';
  static const String reserva = '/reserva';
  static const String pagos = '/pagos';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    sedes: (context) => const SedesView(),
    inicioJugada: (context) => const InicioJView(),
    inicioJugada2: (context) => const InicioJ2View(),
    inicioBiblos: (context) => const InicioBView(),
    inicioFortin: (context) => const InicioFView(),
    reserva: (context) => const ReservaView(),
    pagos: (context) => const PagosView(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case sedes:
        return MaterialPageRoute(builder: (_) => const SedesView());
      case inicioJugada:
        return MaterialPageRoute(builder: (_) => const InicioJView());
      case inicioJugada2:
        return MaterialPageRoute(builder: (_) => const InicioJ2View()); 
      case inicioBiblos:
        return MaterialPageRoute(builder: (_) => const InicioBView());
      case inicioFortin:
        return MaterialPageRoute(builder: (_) => const InicioFView());
      case reserva:
        return MaterialPageRoute(builder: (_) => const ReservaView());
      case pagos:
        return MaterialPageRoute(builder: (_) => const PagosView());
      default:
        return null;
    }
  }
}
