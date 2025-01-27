import 'package:flutter/material.dart';
// Importa tu archivo de rutas
import 'package:booking_system_flutter/routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catastro App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Ruta inicial: por ejemplo, la pantalla de inicio de sesión
      initialRoute: AppRoutes.signIn,
      // Generador de rutas
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

