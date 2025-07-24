// lib/mapbox_access_token.dart

/// Token de acceso para Mapbox Maps SDK
/// Este token debe configurarse antes de usar cualquier funcionalidad de Mapbox
class MapboxAccessToken {
  /// Token público de Mapbox para tu cuenta
  static const String PUBLIC_TOKEN = 'pk.eyJ1Ijoic2FudGlhZ29jdXNpIiwiYSI6ImNsbnhuZzI4YTBmcmIya252cnF6dDVxaWUifQ.g6GUxNjWzPAzSkal0NUS0A';

  /// Configurar el token al inicializar la aplicación
  static void configure() {
    // El token se configura automáticamente desde AndroidManifest.xml
    // Esta clase sirve como referencia centralizada del token
  }

  /// Obtener el token para uso en APIs HTTP (geocodificación, etc.)
  static String get token => PUBLIC_TOKEN;
}