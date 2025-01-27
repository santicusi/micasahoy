import 'package:flutter/material.dart';

class PantallaInformacionFisicaView extends StatefulWidget {
  const PantallaInformacionFisicaView({super.key});

  @override
  State<PantallaInformacionFisicaView> createState() =>
      _PantallaInformacionFisicaViewState();
}

class _PantallaInformacionFisicaViewState
    extends State<PantallaInformacionFisicaView> {
  // Controladores para los campos
  final TextEditingController tipoArmazonController = TextEditingController();
  final TextEditingController materialMurosController = TextEditingController();
  final TextEditingController materialTechoController = TextEditingController();
  final TextEditingController estadoConservacionController =
  TextEditingController();

  // Opciones simuladas para los dropdowns
  final List<String> opcionesTipo = ['Madera', 'Hormigón', 'Metal', 'Ladrillo'];
  final List<String> opcionesEstado = ['Bueno', 'Regular', 'Malo'];

  String? tipoArmazonSeleccionado;
  String? materialMurosSeleccionado;
  String? materialTechoSeleccionado;
  String? estadoConservacionSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Física'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estructura del predio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tipo de Armazón
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de Armazón',
                border: OutlineInputBorder(),
              ),
              value: tipoArmazonSeleccionado,
              items: opcionesTipo.map((String opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  tipoArmazonSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Material de Muros
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Material de Muros',
                border: OutlineInputBorder(),
              ),
              value: materialMurosSeleccionado,
              items: opcionesTipo.map((String opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  materialMurosSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Material de Techo
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Material de Techo',
                border: OutlineInputBorder(),
              ),
              value: materialTechoSeleccionado,
              items: opcionesTipo.map((String opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  materialTechoSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Estado de Conservación
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Estado de Conservación',
                border: OutlineInputBorder(),
              ),
              value: estadoConservacionSeleccionado,
              items: opcionesEstado.map((String estado) {
                return DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  estadoConservacionSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 32),

            const Text(
              'Acabados Principales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Reutilizando los dropdowns para "Acabados"
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Fachada',
                border: OutlineInputBorder(),
              ),
              value: tipoArmazonSeleccionado,
              items: opcionesTipo.map((String opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  tipoArmazonSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Estado de Conservación',
                border: OutlineInputBorder(),
              ),
              value: estadoConservacionSeleccionado,
              items: opcionesEstado.map((String estado) {
                return DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  estadoConservacionSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Botón de enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_validarFormulario()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Información física enviada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context); // Regresa a la pantalla anterior
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, completa todos los campos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Enviar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validación del formulario
  bool _validarFormulario() {
    return tipoArmazonSeleccionado != null &&
        materialMurosSeleccionado != null &&
        materialTechoSeleccionado != null &&
        estadoConservacionSeleccionado != null;
  }
}
