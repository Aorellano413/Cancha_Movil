import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'controllers/sedes_controller.dart';
import 'controllers/reserva_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SedesController()),
        ChangeNotifierProvider(create: (_) => ReservaController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ReservaSports',
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
