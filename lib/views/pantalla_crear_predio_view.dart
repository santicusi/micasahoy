import 'package:flutter/material.dart';

class PantallaCrearPredioView extends StatefulWidget {
  const PantallaCrearPredioView({super.key});

  @override
  State<PantallaCrearPredioView> createState() => _PantallaCrearPredioViewState();
}

class _PantallaCrearPredioViewState extends State<PantallaCrearPredioView> {
  // Controladores para los campos del formulario
  final TextEditingController areaController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();
  final TextEditingController barrioController = TextEditingController();
  final TextEditingController departamentoController = TextEditingController();
  final TextEditingController numeroVerificacionController = TextEditingController();

  // Lista de municipios y tipo de predio (pueden ser dinámicos en el futuro)
  final List<String> municipios = ['Cali', 'Palmira', 'Yumbo', 'Jamundí'];
  final List<String> tiposPredio = ['Residencial', 'Comercial', 'Industrial', 'Rural'];

  String? selectedMunicipio;
  String? selectedTipoPredio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea un nuevo predio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo: Área
            TextField(
              controller: areaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Área',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Dirección
            TextField(
              controller: direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Barrio
            TextField(
              controller: barrioController,
              decoration: const InputDecoration(
                labelText: 'Barrio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Departamento
            TextField(
              controller: departamentoController,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown: Municipio
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Municipio',
                border: OutlineInputBorder(),
              ),
              value: selectedMunicipio,
              items: municipios.map((String municipio) {
                return DropdownMenuItem<String>(
                  value: municipio,
                  child: Text(municipio),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMunicipio = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Dropdown: Tipo de predio
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de predio',
                border: OutlineInputBorder(),
              ),
              value: selectedTipoPredio,
              items: tiposPredio.map((String tipo) {
                return DropdownMenuItem<String>(
                  value: tipo,
                  child: Text(tipo),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTipoPredio = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Campo: Número de verificación
            TextField(
              controller: numeroVerificacionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de verificación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Botón: Crear predio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para crear un nuevo predio
                  if (_validarFormulario()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Predio creado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context); // Retornar a la pantalla anterior
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, llena todos los campos'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Crear predio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validación del formulario
  bool _validarFormulario() {
    return areaController.text.isNotEmpty &&
        direccionController.text.isNotEmpty &&
        barrioController.text.isNotEmpty &&
        departamentoController.text.isNotEmpty &&
        selectedMunicipio != null &&
        selectedTipoPredio != null &&
        numeroVerificacionController.text.isNotEmpty;
  }
}
