import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const ReservaSportsApp());
}

class ReservaSportsApp extends StatelessWidget {
  const ReservaSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ReservaSports",
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.getRoutes(),
    );
  }
}
