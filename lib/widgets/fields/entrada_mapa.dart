import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;
import '../../models/field_definition.dart';
import 'dart:math' as math;
import '../../strapi_service.dart';

class EntradaMapa extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final Map<String, dynamic>? initialValue;
  final bool enabled;
  final int? predioId;

  // Paleta de colores GEOCAT
  static const Color primaryGreen = Color(0xFF7CB342);
  static const Color darkGreen = Color(0xFF558B2F);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkRed = Color(0xFFC62828);
  static const Color primaryBrown = Color(0xFF8D6E63);
  static const Color darkBrown = Color(0xFF5D4037);
  static const Color accentGold = Color(0xFFFBC02D);
  static const Color darkGold = Color(0xFFF9A825);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF666666);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  const EntradaMapa({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
    this.predioId,
  }) : super(key: key);

  @override
  _EntradaMapaState createState() => _EntradaMapaState();
}

class _EntradaMapaState extends State<EntradaMapa>
    with AutomaticKeepAliveClientMixin {

  // ============ VARIABLES EXISTENTES ============
  LatLng? _marker;
  String direccion = '';
  final Location _location = Location();
  late MapController _mapController;
  double _zoom = 15;

  // Variables para dibujo básico
  bool _isDrawingMode = false;
  String _currentDrawMode = 'none';
  List<LatLng> _currentLinePoints = [];
  List<LatLng> _currentPolygonPoints = [];
  List<Map<String, dynamic>> _drawnGeometries = [];
  List<Polyline> _lines = [];
  List<Polygon> _polygons = [];
  List<Marker> _points = [];
  LatLng? _predioCenter;

  // ============ VARIABLES NUEVAS PARA RESTRICCIONES ============
  final StrapiService _strapiService = StrapiService();
  List<List<LatLng>> _predioPolygons = []; // Polígonos del predio
  bool _isLoadingGeometry = false;
  String? _geometryError;

  // ✨ NUEVO: Variables para proyección de coordenadas
  late proj4.Projection _srcProj; // EPSG:9377 (coordenadas del predio)
  late proj4.Projection _dstProj; // EPSG:4326 (WGS84 para el mapa)

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _isDrawingMode = widget.def.context['enableDrawing'] == true;

    // ✨ NUEVO: Inicializar proyecciones
    _initializeProjections();

    // ✨ NUEVO: Cargar geometría del predio primero
    if (widget.predioId != null && _isDrawingMode) {
      _cargarGeometriaPredio();
    } else {
      _inicializarUbicacionNormal();
    }
  }

  /// Inicializa las proyecciones de coordenadas
  void _initializeProjections() {
    try {
      // ✅ EPSG:9377 - MAGNA-SIRGAS 2018 / Origen-Nacional (parámetros correctos)
      _srcProj = proj4.Projection.add('EPSG:9377',
          '+proj=tmerc +lat_0=4 +lon_0=-73 +k=0.9992 +x_0=5000000 +y_0=2000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'
      );

      // EPSG:4326 - WGS84 (coordenadas geográficas)
      _dstProj = proj4.Projection.get('EPSG:4326')!;

      print('✅ Proyecciones inicializadas correctamente');
      print('📍 EPSG:9377: Origen Nacional Colombia (lat_0=4°, lon_0=-73°, x_0=5000000, y_0=2000000)');
    } catch (e) {
      print('❌ Error inicializando proyecciones: $e');
      // Fallback: usar conversión aproximada si falla proj4dart
    }
  }

  // ============ MÉTODOS NUEVOS PARA RESTRICCIONES ============

  /// Carga la geometría del predio desde Strapi
  Future<void> _cargarGeometriaPredio() async {
    setState(() => _isLoadingGeometry = true);

    try {
      // 🔄 CAMBIO: Usar el nuevo método corregido
      final geometria = await _strapiService.getGeometriaPredioCorregida(widget.predioId!);

      if (geometria != null) {
        _procesarGeometriaPredio(geometria);
      } else {
        setState(() {
          _geometryError = 'No se encontró geometría para este predio';
          _isLoadingGeometry = false;
        });
        _inicializarUbicacionNormal();
      }
    } catch (e) {
      setState(() {
        _geometryError = 'Error al cargar geometría: $e';
        _isLoadingGeometry = false;
      });
      _inicializarUbicacionNormal();
    }
  }

  /// Procesa la geometría GeoJSON del predio
  void _procesarGeometriaPredio(Map<String, dynamic> geometria) {
    try {
      _predioPolygons.clear();
      LatLng? centroide;
      double totalLat = 0, totalLng = 0;
      int totalPuntos = 0;

      // 🔄 MEJORADO: Manejar tanto MultiPolygon como Polygon
      if (geometria['type'] == 'MultiPolygon' && geometria['coordinates'] != null) {
        final coordinates = geometria['coordinates'] as List;

        for (var polygon in coordinates) {
          for (var ring in polygon) {
            final points = _convertirCoordenadasALatLng(ring);
            if (points.isNotEmpty) {
              _predioPolygons.add(points);
              for (var point in points) {
                totalLat += point.latitude;
                totalLng += point.longitude;
                totalPuntos++;
              }
            }
          }
        }
      } else if (geometria['type'] == 'Polygon' && geometria['coordinates'] != null) {
        final coordinates = geometria['coordinates'] as List;

        for (var ring in coordinates) {
          final points = _convertirCoordenadasALatLng(ring);
          if (points.isNotEmpty) {
            _predioPolygons.add(points);
            for (var point in points) {
              totalLat += point.latitude;
              totalLng += point.longitude;
              totalPuntos++;
            }
          }
        }
      } else {
        throw Exception('Tipo de geometría no soportado: ${geometria['type']}');
      }

      // Calcular centroide para centrar el mapa
      if (totalPuntos > 0) {
        centroide = LatLng(totalLat / totalPuntos, totalLng / totalPuntos);
      }

      _predioCenter = centroide; // Guardar para uso posterior

      setState(() {
        _isLoadingGeometry = false;
        if (centroide != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(centroide!, 16);
          });
        }
      });

      print('✅ Geometría del predio cargada: ${_predioPolygons.length} polígonos');
      print('✅ Centroide calculado: $centroide');
    } catch (e) {
      setState(() {
        _geometryError = 'Error al procesar geometría: $e';
        _isLoadingGeometry = false;
      });
      _inicializarUbicacionNormal();
      print('❌ Error procesando geometría: $e');
    }
  }

  /// Convierte array de coordenadas proyectadas a LatLng geográficas
  List<LatLng> _convertirCoordenadasALatLng(List<dynamic> coordenadas) {
    final points = <LatLng>[];

    for (var coord in coordenadas) {
      if (coord is List && coord.length >= 2) {
        final x = coord[0].toDouble(); // Coordenada X proyectada
        final y = coord[1].toDouble(); // Coordenada Y proyectada

        try {
          // ✨ NUEVO: Conversión precisa con proj4dart
          final latLng = _convertirProyectadaAGeografica(x, y);
          points.add(latLng);

          // Debug: mostrar algunas conversiones
          if (points.length <= 3) {
            print('🔄 Coord proyectada: ($x, $y) → Geográfica: (${latLng.latitude}, ${latLng.longitude})');
          }
        } catch (e) {
          print('❌ Error convirtiendo coordenada ($x, $y): $e');
          // Fallback: conversión aproximada
          final latLng = _convertirCoordenadasAproximada(x, y);
          points.add(latLng);
        }
      }
    }

    return points;
  }

  /// Conversión precisa usando proj4dart
  LatLng _convertirProyectadaAGeografica(double x, double y) {
    final point = proj4.Point(x: x, y: y); // ✨ Usar alias
    final transformed = _srcProj.transform(_dstProj, point);
    return LatLng(transformed.y, transformed.x); // y=lat, x=lng
  }

  /// Conversión aproximada como fallback
  LatLng _convertirCoordenadasAproximada(double x, double y) {
    // ✅ Parámetros correctos para EPSG:9377
    const double falseEasting = 5000000.0;    // x_0
    const double falseNorthing = 2000000.0;   // y_0
    const double centralMeridian = -73.0;     // lon_0
    const double latitudeOrigin = 4.0;        // lat_0
    const double scaleFactor = 0.9992;        // k

    // Conversión aproximada usando parámetros de Transverse Mercator
    double lng = centralMeridian + ((x - falseEasting) / (111320.0 * scaleFactor * math.cos(latitudeOrigin * math.pi / 180)));
    double lat = latitudeOrigin + ((y - falseNorthing) / 111000.0);

    return LatLng(lat, lng);
  }

  /// Verifica si un punto está dentro de algún polígono del predio
  bool _estaDentroDePredio(LatLng punto) {
    if (_predioPolygons.isEmpty) return true; // Si no hay restricción, permitir

    for (var polygon in _predioPolygons) {
      if (_puntoEnPoligono(punto, polygon)) {
        return true;
      }
    }
    return false;
  }

  /// Convierte coordenadas geográficas de vuelta a proyectadas (para envío)
  Map<String, dynamic> _convertirGeograficaAProyectada(Map<String, dynamic> geometryData) {
    try {
      if (geometryData['type'] == 'Point') {
        final coords = geometryData['coordinates'] as List;
        final lat = coords[1].toDouble();
        final lng = coords[0].toDouble();

        final point = proj4.Point(x: lng, y: lat); // ✨ Usar alias
        final projected = _dstProj.transform(_srcProj, point);

        return {
          'type': 'Point',
          'coordinates': [projected.x, projected.y],
          'crs': {'type': 'name', 'properties': {'name': 'EPSG:9377'}}
        };
      } else if (geometryData['type'] == 'LineString') {
        final coords = geometryData['coordinates'] as List;
        final projectedCoords = coords.map((coord) {
          final lat = coord[1].toDouble();
          final lng = coord[0].toDouble();
          final point = proj4.Point(x: lng, y: lat); // ✨ Usar alias
          final projected = _dstProj.transform(_srcProj, point);
          return [projected.x, projected.y];
        }).toList();

        return {
          'type': 'LineString',
          'coordinates': projectedCoords,
          'crs': {'type': 'name', 'properties': {'name': 'EPSG:9377'}}
        };
      } else if (geometryData['type'] == 'Polygon') {
        final coords = geometryData['coordinates'] as List;
        final projectedCoords = coords.map((ring) {
          return (ring as List).map((coord) {
            final lat = coord[1].toDouble();
            final lng = coord[0].toDouble();
            final point = proj4.Point(x: lng, y: lat); // ✨ Usar alias
            final projected = _dstProj.transform(_srcProj, point);
            return [projected.x, projected.y];
          }).toList();
        }).toList();

        return {
          'type': 'Polygon',
          'coordinates': projectedCoords,
          'crs': {'type': 'name', 'properties': {'name': 'EPSG:9377'}}
        };
      }

      return geometryData; // Retornar sin cambios si no es un tipo soportado
    } catch (e) {
      print('❌ Error convirtiendo a proyectadas: $e');
      return geometryData; // Retornar original en caso de error
    }
  }

  /// Algoritmo Ray Casting para verificar si un punto está dentro de un polígono
  bool _puntoEnPoligono(LatLng punto, List<LatLng> poligono) {
    if (poligono.length < 3) return false;

    bool dentro = false;
    int j = poligono.length - 1;

    for (int i = 0; i < poligono.length; i++) {
      final xi = poligono[i].longitude;
      final yi = poligono[i].latitude;
      final xj = poligono[j].longitude;
      final yj = poligono[j].latitude;
      final x = punto.longitude;
      final y = punto.latitude;

      if (((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
        dentro = !dentro;
      }
      j = i;
    }
    return dentro;
  }

  /// Muestra mensaje de error cuando se dibuja fuera del predio
  void _mostrarErrorFueraDePredio() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('⚠️ No puedes dibujar fuera de los límites de tu predio'),
        backgroundColor: EntradaMapa.accentGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _centrarEnPredio() {
    if (_predioCenter != null) {
      _mapController.move(_predioCenter!, 16);
    }
  }

  // ============ MÉTODOS EXISTENTES MODIFICADOS ============

  void _inicializarUbicacionNormal() {
    final initial = widget.initialValue;
    if (initial != null &&
        initial['type'] == 'Point' &&
        initial['coordinates'] is List &&
        initial['coordinates'].length == 2) {
      final coords = initial['coordinates'];
      _marker = LatLng(coords[1], coords[0]);
    }
    // ❌ REMOVIDO: No auto-obtener ubicación actual
  }

  void _onTap(TapPosition tapPosition, LatLng pos) {
    if (_isDrawingMode) {
      _handleDrawingTap(pos);
    } else {
      setState(() => _marker = pos);
      widget.onChanged({
        'type': 'Point',
        'coordinates': [pos.longitude, pos.latitude],
      });
      _obtenerDireccion(pos.latitude, pos.longitude);
    }
  }

  void _handleDrawingTap(LatLng pos) {
    // ✨ NUEVA VALIDACIÓN: Verificar si está dentro del predio
    if (!_estaDentroDePredio(pos)) {
      _mostrarErrorFueraDePredio();
      return;
    }

    switch (_currentDrawMode) {
      case 'point':
        _addPoint(pos);
        break;
      case 'line':
        _addLinePoint(pos);
        break;
      case 'polygon':
        _addPolygonPoint(pos);
        break;
      default:
        setState(() => _marker = pos);
        _obtenerDireccion(pos.latitude, pos.longitude);
        break;
    }
  }

  void _addPoint(LatLng pos) {
    final marker = Marker(
      point: pos,
      width: 40,
      height: 40,
      child: Icon(Icons.location_on, color: EntradaMapa.primaryGreen, size: 40),
    );

    setState(() {
      _points.add(marker);
      _drawnGeometries.add({
        'type': 'Point',
        'coordinates': [pos.longitude, pos.latitude],
      });
    });

    _updateOutputData();
  }

  void _addLinePoint(LatLng pos) {
    setState(() {
      _currentLinePoints.add(pos);

      if (_currentLinePoints.length >= 2) {
        _createLine();
        return;
      }
    });
  }

  void _createLine() {
    final line = Polyline(
      points: List.from(_currentLinePoints),
      color: EntradaMapa.primaryGreen,
      strokeWidth: 3.0,
    );

    setState(() {
      _lines.add(line);
      _drawnGeometries.add({
        'type': 'LineString',
        'coordinates': _currentLinePoints.map((p) => [p.longitude, p.latitude]).toList(),
      });
      _currentLinePoints.clear();
    });

    _updateOutputData();
  }

  void _addPolygonPoint(LatLng pos) {
    setState(() {
      _currentPolygonPoints.add(pos);
    });
  }

  void _finishPolygon() {
    if (_currentPolygonPoints.length < 3) return;

    final closedPoints = List<LatLng>.from(_currentPolygonPoints);
    if (closedPoints.first != closedPoints.last) {
      closedPoints.add(closedPoints.first);
    }

    final polygon = Polygon(
      points: closedPoints,
      color: EntradaMapa.primaryGreen.withOpacity(0.3),
      borderColor: EntradaMapa.primaryGreen,
      borderStrokeWidth: 2.0,
    );

    setState(() {
      _polygons.add(polygon);
      _drawnGeometries.add({
        'type': 'Polygon',
        'coordinates': [closedPoints.map((p) => [p.longitude, p.latitude]).toList()],
      });
      _currentPolygonPoints.clear();
    });

    _updateOutputData();
  }

  void _updateOutputData() {
    Map<String, dynamic> geometryData;

    if (_drawnGeometries.isEmpty && _marker != null) {
      geometryData = {
        'type': 'Point',
        'coordinates': [_marker!.longitude, _marker!.latitude],
      };
    } else if (_drawnGeometries.length == 1) {
      geometryData = _drawnGeometries.first;
    } else if (_drawnGeometries.length > 1) {
      geometryData = {
        'type': 'MultipleGeometries',
        'geometries': _drawnGeometries,
        'count': _drawnGeometries.length,
      };
    } else {
      return; // No hay datos
    }

    // ✨ NUEVO: Convertir de vuelta a coordenadas proyectadas antes de enviar
    final projectedData = _convertirGeograficaAProyectada(geometryData);
    widget.onChanged(projectedData);
  }

  void _setDrawMode(String mode) {
    setState(() => _currentDrawMode = mode);
  }

  void _clearAllDrawings() {
    setState(() {
      _drawnGeometries.clear();
      _currentLinePoints.clear();
      _currentPolygonPoints.clear();
      _points.clear();
      _lines.clear();
      _polygons.clear();
      _currentDrawMode = 'none';
    });

    _updateOutputData();
  }

  Future<void> _obtenerDireccion(double lat, double lng) async {
    final accessToken = 'pk.eyJ1Ijoic2FudGlhZ29jdXNpIiwiYSI6ImNsbnhuZzI4YTBmcmIya252cnF6dDVxaWUifQ.g6GUxNjWzPAzSkal0NUS0A';
    final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json?access_token=$accessToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final place = data['features'][0]['place_name'];
          setState(() => direccion = place);
        }
      } else {
        setState(() => direccion = 'Dirección no encontrada');
      }
    } catch (_) {
      setState(() => direccion = 'Error obteniendo dirección');
    }
  }

  // ✅ ARREGLADO: Zoom sin reposicionar
  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 1).clamp(1, 18);
    });
    _mapController.moveAndRotate(_mapController.camera.center, _zoom, 0);
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 1).clamp(1, 18);
    });
    _mapController.moveAndRotate(_mapController.camera.center, _zoom, 0);
  }

  // ============ WIDGETS ============

  Widget _buildDrawingControls() {
    if (!_isDrawingMode) return const SizedBox.shrink();

    return Positioned(
      left: 12,
      top: 12,
      child: Container(
        decoration: BoxDecoration(
          color: EntradaMapa.pureWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoadingGeometry)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: EntradaMapa.primaryGreen,
                ),
              )
            else ...[
              IconButton(
                onPressed: () => _setDrawMode('point'),
                icon: Icon(
                  Icons.place,
                  color: _currentDrawMode == 'point'
                      ? EntradaMapa.primaryGreen
                      : EntradaMapa.primaryBrown,
                  size: 24,
                ),
                tooltip: 'Dibujar punto',
              ),
              IconButton(
                onPressed: () => _setDrawMode('line'),
                icon: Icon(
                  Icons.timeline,
                  color: _currentDrawMode == 'line'
                      ? EntradaMapa.primaryGreen
                      : EntradaMapa.primaryBrown,
                  size: 24,
                ),
                tooltip: 'Dibujar línea',
              ),
              IconButton(
                onPressed: () => _setDrawMode('polygon'),
                icon: Icon(
                  Icons.pentagon_outlined,
                  color: _currentDrawMode == 'polygon'
                      ? EntradaMapa.primaryGreen
                      : EntradaMapa.primaryBrown,
                  size: 24,
                ),
                tooltip: 'Dibujar polígono',
              ),
              if (_currentDrawMode == 'polygon' && _currentPolygonPoints.length >= 3)
                IconButton(
                  onPressed: _finishPolygon,
                  icon: Icon(Icons.check, color: EntradaMapa.primaryGreen, size: 24),
                  tooltip: 'Terminar polígono',
                ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: EntradaMapa.lightGrey,
              ),
              IconButton(
                onPressed: _clearAllDrawings,
                icon: Icon(Icons.clear_all, color: EntradaMapa.primaryRed, size: 24),
                tooltip: 'Borrar todo',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Positioned(
      top: 12,
      right: 12,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: EntradaMapa.pureWhite,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _zoomIn,
              icon: Icon(Icons.zoom_in, color: EntradaMapa.primaryBrown),
              tooltip: 'Acercar',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: EntradaMapa.pureWhite,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _zoomOut,
              icon: Icon(Icons.zoom_out, color: EntradaMapa.primaryBrown),
              tooltip: 'Alejar',
            ),
          ),
          if (_predioCenter != null) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: EntradaMapa.primaryGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: EntradaMapa.primaryGreen.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _centrarEnPredio,
                icon: const Icon(Icons.home_outlined, color: EntradaMapa.pureWhite),
                tooltip: 'Centrar en predio',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EntradaMapa.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EntradaMapa.lightGrey.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_geometryError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: EntradaMapa.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: EntradaMapa.accentGold.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_outlined, color: EntradaMapa.darkGold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _geometryError!,
                      style: TextStyle(
                        fontSize: 13,
                        color: EntradaMapa.primaryBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (_marker != null && !_isDrawingMode)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: EntradaMapa.primaryRed),
                    const SizedBox(width: 6),
                    Text(
                      'Ubicación Seleccionada',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: EntradaMapa.darkBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Lat: ${_marker!.latitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 13, color: EntradaMapa.primaryBrown),
                ),
                Text(
                  'Lng: ${_marker!.longitude.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 13, color: EntradaMapa.primaryBrown),
                ),
                if (direccion.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    direccion,
                    style: TextStyle(fontSize: 12, color: EntradaMapa.textSecondary),
                  ),
                ],
              ],
            ),

          if (_isDrawingMode)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_predioPolygons.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: EntradaMapa.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: EntradaMapa.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.home_outlined, size: 16, color: EntradaMapa.primaryGreen),
                            const SizedBox(width: 6),
                            Text(
                              'Predio Cargado',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: EntradaMapa.darkGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_predioPolygons.length} área${_predioPolygons.length > 1 ? 's' : ''} definida${_predioPolygons.length > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 12, color: EntradaMapa.primaryBrown),
                        ),
                        Text(
                          'Puntos: ${_predioPolygons.fold(0, (sum, polygon) => sum + (polygon.length - 1))}',
                          style: TextStyle(fontSize: 12, color: EntradaMapa.textSecondary),
                        ),
                      ],
                    ),
                  ),

                Row(
                  children: [
                    Icon(Icons.draw_outlined, size: 16, color: EntradaMapa.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Herramientas de Dibujo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: EntradaMapa.darkBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  'Elementos dibujados: ${_drawnGeometries.length}',
                  style: TextStyle(fontSize: 13, color: EntradaMapa.primaryBrown),
                ),

                if (_currentDrawMode != 'none')
                  Text(
                    'Modo actual: $_currentDrawMode',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: EntradaMapa.primaryGreen,
                    ),
                  ),

                if (_currentDrawMode == 'line' && _currentLinePoints.isNotEmpty)
                  Text(
                    'Puntos de línea: ${_currentLinePoints.length}',
                    style: TextStyle(fontSize: 12, color: EntradaMapa.textSecondary),
                  ),

                if (_currentDrawMode == 'polygon' && _currentPolygonPoints.isNotEmpty)
                  Text(
                    'Puntos de polígono: ${_currentPolygonPoints.length}',
                    style: TextStyle(fontSize: 12, color: EntradaMapa.textSecondary),
                  ),

                if (_predioPolygons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: EntradaMapa.accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: EntradaMapa.darkGold),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Solo puedes dibujar dentro de tu predio',
                            style: TextStyle(
                              fontSize: 11,
                              color: EntradaMapa.primaryBrown,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final defaultLat = widget.def.context['defaultLat'] as double? ?? 3.4516;
    final defaultLng = widget.def.context['defaultLng'] as double? ?? -76.5320;
    final center = _marker ?? LatLng(defaultLat, defaultLng);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✨ CAMBIO PRINCIPAL: Aumentar altura del mapa de 300 a 500px
        Container(
          height: 500, // ← Cambiado de 300 a 500px
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: _zoom,
                    onTap: _onTap,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                      additionalOptions: {
                        'accessToken': 'pk.eyJ1Ijoic2FudGlhZ29jdXNpIiwiYSI6ImNsbnhuZzI4YTBmcmIya252cnF6dDVxaWUifQ.g6GUxNjWzPAzSkal0NUS0A',
                        'id': 'mapbox/streets-v11',
                      },
                    ),
                    // Mostrar límites del predio con colores GEOCAT
                    if (_predioPolygons.isNotEmpty)
                      PolygonLayer(
                        polygons: _predioPolygons.map((points) => Polygon(
                          points: points,
                          color: EntradaMapa.primaryGreen.withOpacity(0.15),
                          borderColor: EntradaMapa.primaryGreen,
                          borderStrokeWidth: 3.0,
                          isFilled: true,
                        )).toList(),
                      ),
                    // Polígonos dibujados por el usuario
                    if (_polygons.isNotEmpty)
                      PolygonLayer(polygons: _polygons),
                    // Líneas dibujadas
                    if (_lines.isNotEmpty)
                      PolylineLayer(polylines: _lines),
                    // Línea temporal mientras se dibuja
                    if (_currentLinePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _currentLinePoints,
                            color: EntradaMapa.primaryRed.withOpacity(0.7),
                            strokeWidth: 2.0,
                            isDotted: true,
                          ),
                        ],
                      ),
                    // Polígono temporal mientras se dibuja
                    if (_currentPolygonPoints.isNotEmpty && _currentPolygonPoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _currentPolygonPoints,
                            color: EntradaMapa.primaryRed.withOpacity(0.7),
                            strokeWidth: 2.0,
                            isDotted: true,
                          ),
                        ],
                      ),
                    // Marcadores
                    MarkerLayer(
                      markers: [
                        if (_marker != null && !_isDrawingMode)
                          Marker(
                            point: _marker!,
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_on, color: EntradaMapa.primaryRed, size: 40),
                          ),
                        ..._points,
                        ..._currentLinePoints.map((point) => Marker(
                          point: point,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: EntradaMapa.primaryRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )),
                        ..._currentPolygonPoints.map((point) => Marker(
                          point: point,
                          width: 20,
                          height: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: EntradaMapa.primaryRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
                _buildDrawingControls(),
                _buildZoomControls(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoPanel(),
      ],
    );
  }
}