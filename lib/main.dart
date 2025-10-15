import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/theme_controller.dart';
import 'controllers/sedes_controller.dart';
import 'controllers/reserva_controller.dart';
import 'controllers/canchas_jugada2_controller.dart';
import 'controllers/canchas_biblos_controller.dart';
import 'controllers/canchas_fortin_controller.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => SedesController()),
        ChangeNotifierProvider(create: (_) => ReservaController()),
        ChangeNotifierProvider(create: (_) => CanchasJugada2Controller()),
        ChangeNotifierProvider(create: (_) => CanchasBiblosController()),
        ChangeNotifierProvider(create: (_) => CanchasFortinController()),
      ],
      child: const ReservaSportsApp(),
    ),
  );
}

class ReservaSportsApp extends StatelessWidget {
  const ReservaSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReservaSports',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeCtrl.mode,
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
