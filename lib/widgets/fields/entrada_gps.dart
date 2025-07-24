import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../../models/field_definition.dart';

class EntradaGPS extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<Map<String, double>> onChanged;
  final Map<String, double>? initialValue;
  final bool enabled;


  const EntradaGPS({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  _EntradaGPSState createState() => _EntradaGPSState();
}

class _EntradaGPSState extends State<EntradaGPS> {
  String _status = 'No obtenido';
  final Location _location = Location();

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null &&
        widget.initialValue!['lat'] != null &&
        widget.initialValue!['lng'] != null) {
      _status =
      'Lat: ${widget.initialValue!['lat']}, Lng: ${widget.initialValue!['lng']}';
    }

    _checkPermission();
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        setState(() => _status = 'Servicio de ubicación desactivado');
        return;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() => _status = 'Permiso de ubicación denegado');
        return;
      }
    }
  }

  Future<void> _obtenerPosicion() async {
    try {
      final locData = await _location.getLocation();
      final coords = {
        'lat': locData.latitude ?? 0.0,
        'lng': locData.longitude ?? 0.0
      };
      setState(() =>
      _status = 'Lat: ${coords['lat']}, Lng: ${coords['lng']}');
      widget.onChanged(coords);
    } catch (e) {
      setState(() => _status = 'Error al obtener posición: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.def.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.gps_fixed),
          label: const Text('Obtener ubicación'),
          onPressed: _obtenerPosicion,
        ),
        const SizedBox(height: 6),
        Text(_status),
      ],
    );
  }
}


