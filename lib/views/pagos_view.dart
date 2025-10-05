// views/pagos_view.dart
import 'package:flutter/material.dart';

class PagosView extends StatelessWidget {
  const PagosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Opciones de pago"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), 
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                
              },
              child: const Text("Pago con tarjeta"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
              
              },
              child: const Text("Pago en efectivo"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                
              },
              child: const Text("Transferencia bancaria"),
            ),
          ],
        ),
      ),
    );
  }
}
