import 'package:booking_system_flutter/views/pantalla_enviado_view.dart';
import 'package:flutter/material.dart';
import 'package:booking_system_flutter/routes/routes.dart';
import 'package:booking_system_flutter/strapi_service.dart';
import 'package:booking_system_flutter/views/dashboard_home_view.dart';
import 'package:booking_system_flutter/views/sign_in_view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'mapbox_access_token.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔴 FLUTTER ERROR: ${details.exception}');
    if (details.stack != null) {
      debugPrint('🔴 STACK TRACE:\n${details.stack}');
    }
  };

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isLoggedIn;
  String? sessionExpiredMessage;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    try {
      final strapiService = StrapiService();
      final token = await strapiService.getToken();

      debugPrint('🟡 Token obtenido: $token');

      if (token == null) {
        debugPrint('🔴 No hay token, usuario no logueado.');
        setState(() {
          isLoggedIn = false;
        });
        return;
      }

      final verifyResponse = await strapiService.verifyToken();

      debugPrint('🟢 Resultado de verificar token: $verifyResponse');

      if (verifyResponse['success']) {
        setState(() {
          isLoggedIn = true;
        });
      } else {
        debugPrint('🟠 Token inválido, sesión expirada.');
        await strapiService.deleteToken();
        setState(() {
          isLoggedIn = false;
          sessionExpiredMessage = 'Tu sesión ha expirado. Por favor inicia sesión nuevamente.';
        });
      }
    } catch (e, stack) {
      debugPrint('❌ Error al verificar token: $e');
      debugPrint('📌 Stacktrace:\n$stack');
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'GEOCAT',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map?;
          final initialTab = args?['tab'] ?? 0;
          return DashboardHomeView(initialIndex: initialTab);
        },
        '/enviados': (context) => const PantallaEnviadoView(),
      },
      onGenerateRoute: AppRoutes.generateRoute,
      home: Builder(
        builder: (context) {
          if (sessionExpiredMessage != null) {
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(sessionExpiredMessage!)),
              );
            });
          }

          debugPrint('🟩 Mostrando pantalla inicial: ${isLoggedIn! ? 'Dashboard' : 'Login'}');

          return isLoggedIn! ? const DashboardHomeView() : const SignInView();
        },
      ),
    );
  }
}
