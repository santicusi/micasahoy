import 'package:flutter/material.dart';

class PantallaInformacionJuridicaView extends StatefulWidget {
  const PantallaInformacionJuridicaView({super.key});

  @override
  State<PantallaInformacionJuridicaView> createState() =>
      _PantallaInformacionJuridicaViewState();
}

class _PantallaInformacionJuridicaViewState
    extends State<PantallaInformacionJuridicaView> {
  // Historial de propietarios
  final TextEditingController propietarioActualController =
  TextEditingController();
  final TextEditingController fechaAdquisicionController =
  TextEditingController();
  final TextEditingController fechaVentaController = TextEditingController();
  final TextEditingController documentoPropietarioController =
  TextEditingController();

  // Restricciones legales
  final List<String> tiposRestriccion = ['Embargo', 'Gravamen', 'Otro'];
  String? tipoRestriccionSeleccionado;
  final TextEditingController fechaInicioRestriccionController =
  TextEditingController();
  final TextEditingController documentoRestriccionController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Jurídica'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Historial de Propietarios
            const Text(
              'Historial de Propietarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Campo: Nombre del propietario
            TextField(
              controller: propietarioActualController,
              decoration: const InputDecoration(
                labelText: 'Nombre del propietario actual',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de Adquisición
            TextField(
              controller: fechaAdquisicionController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Fecha de adquisición',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Fecha de Venta
            TextField(
              controller: fechaVentaController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Fecha de venta (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Documento del propietario
            TextField(
              controller: documentoPropietarioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Documento de identidad del propietario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Restricciones Legales
            const Text(
              'Restricciones Legales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tipo de Restricción
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de restricción',
                border: OutlineInputBorder(),
              ),
              value: tipoRestriccionSeleccionado,
              items: tiposRestriccion.map((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  tipoRestriccionSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Fecha de inicio de la restricción
            TextField(
              controller: fechaInicioRestriccionController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Fecha de inicio de la restricción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Documento de la restricción
            TextField(
              controller: documentoRestriccionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Documento asociado a la restricción',
                border: OutlineInputBorder(),
              ),
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
                        content: Text('Información jurídica enviada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context); // Regresa a la pantalla anterior
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, completa todos los campos requeridos'),
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
    return propietarioActualController.text.isNotEmpty &&
        fechaAdquisicionController.text.isNotEmpty &&
        documentoPropietarioController.text.isNotEmpty &&
        tipoRestriccionSeleccionado != null &&
        fechaInicioRestriccionController.text.isNotEmpty &&
        documentoRestriccionController.text.isNotEmpty;
  }
}
