import 'package:flutter/material.dart';
import 'package:booking_system_flutter/views/sign_in_view.dart';
import 'package:booking_system_flutter/views/sign_up_view.dart';
import 'package:booking_system_flutter/views/dashboard_home_view.dart';
import 'package:booking_system_flutter/views/pantalla_enviado_view.dart';
import 'package:booking_system_flutter/views/pantalla_perfil_view.dart';


class AppRoutes {
  // Nombres de las rutas
  static const signIn = '/sign_in';
  static const signUp = '/sign_up';
  static const dashboardHome = '/dashboard_home';
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


      case pantallaEnviados:
        return MaterialPageRoute(
          builder: (_) => const PantallaEnviadoView(),
        );

      case pantallaPerfil:
        return MaterialPageRoute(
          builder: (_) => const PantallaPerfilView(),
        );

      default:
      // Si no coincide ninguna ruta, ir al login
        return MaterialPageRoute(builder: (_) => const SignInView());
    }
  }
}

