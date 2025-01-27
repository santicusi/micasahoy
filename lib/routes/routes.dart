import 'package:flutter/material.dart';
import 'package:booking_system_flutter/views/sign_in_view.dart';
import 'package:booking_system_flutter/views/sign_up_view.dart';
import 'package:booking_system_flutter/views/dashboard_home_view.dart';
import 'package:booking_system_flutter/views/pantalla_crear_predio_view.dart';
import 'package:booking_system_flutter/views/pantalla_registros_view.dart';
import 'package:booking_system_flutter/views/pantalla_informacion_fisica_view.dart';
import 'package:booking_system_flutter/views/pantalla_informacion_juridica_view.dart';
import 'package:booking_system_flutter/views/pantalla_enviado_view.dart';
import 'package:booking_system_flutter/views/pantalla_perfil_view.dart';

class AppRoutes {
  // Nombres de las rutas
  static const signIn = '/sign_in';
  static const signUp = '/sign_up';
  static const dashboardHome = '/dashboard_home';
  static const pantallaCrearPredio = '/pantalla_crear_predio';
  static const pantallaRegistros = '/pantalla_registros';
  static const pantallaInformacionFisica = '/pantalla_informacion_fisica';
  static const pantallaInformacionJuridica = '/pantalla_informacion_juridica';
  static const pantallaEnviados = '/pantalla_enviado';
  static const pantallaPerfil = '/pantalla_perfil';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInView());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpView());
      case dashboardHome:
        return MaterialPageRoute(builder: (_) => const DashboardHomeView());
      case pantallaCrearPredio:
        return MaterialPageRoute(builder: (_) => const PantallaCrearPredioView());
      case pantallaRegistros:
      // Recibe argumentos opcionales
        final arguments = settings.arguments as Map?;
        return MaterialPageRoute(
          builder: (_) => PantallaRegistrosView(),
          settings: RouteSettings(arguments: arguments),
        );
      case pantallaInformacionFisica:
        return MaterialPageRoute(builder: (_) => const PantallaInformacionFisicaView());
      case pantallaInformacionJuridica:
        return MaterialPageRoute(builder: (_) => const PantallaInformacionJuridicaView());
      case pantallaEnviados:
        return MaterialPageRoute(builder: (_) => const PantallaEnviadoView());
      case pantallaPerfil:
        return MaterialPageRoute(builder: (_) => const PantallaPerfilView());
      default:
      // Ruta por defecto si no se encuentra ninguna
        return MaterialPageRoute(builder: (_) => const SignInView());
    }
  }
}
