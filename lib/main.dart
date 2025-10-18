import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// 👇 Importa las opciones de Firebase generadas automáticamente
import 'firebase_options.dart';

import 'controllers/theme_controller.dart';
import 'controllers/sedes_controller.dart';
import 'controllers/reserva_controller.dart';
import 'controllers/canchas_controller.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializar Firebase con las opciones correctas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => SedesController()),
        ChangeNotifierProvider(create: (_) => ReservaController()),
        ChangeNotifierProvider(create: (_) => CanchasController()),
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
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}