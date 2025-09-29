import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
         
          Expanded(
            flex: 2,
            child: GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 3,
              children: List.generate(9, (index) {
                return Image.asset(
                  "assets/images/img${index + 1}.jpg",
                  fit: BoxFit.cover,
                );
              }),
            ),
          ),
          
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Bienvenido a",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "ReservaSports",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tu mejor aliado para practicar fútbol en Valledupar",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.sedes);
                    },
                    child: const Text("Usuario"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Administrador"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
