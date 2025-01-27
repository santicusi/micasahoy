import 'package:flutter/material.dart';
import 'package:booking_system_flutter/routes/routes.dart';

class PantallaPerfilView extends StatefulWidget {
  const PantallaPerfilView({super.key});

  @override
  State<PantallaPerfilView> createState() => _PantallaPerfilViewState();
}

class _PantallaPerfilViewState extends State<PantallaPerfilView> {
  bool isEditing = false; // Modo edición activado/desactivado

  // Controladores para los campos del perfil con valores iniciales
  final TextEditingController nombreController =
  TextEditingController(text: 'Juan');
  final TextEditingController apellidoController =
  TextEditingController(text: 'Pérez');
  final TextEditingController correoController =
  TextEditingController(text: 'juanperez@gmail.com');
  final TextEditingController telefonoController =
  TextEditingController(text: '3001234567');
  final TextEditingController documentoController =
  TextEditingController(text: '123456789');

  // Valores iniciales para restaurar al cancelar
  late String nombreInicial;
  late String apellidoInicial;
  late String correoInicial;
  late String telefonoInicial;
  late String documentoInicial;

  @override
  void initState() {
    super.initState();
    // Guardar valores iniciales
    nombreInicial = nombreController.text;
    apellidoInicial = apellidoController.text;
    correoInicial = correoController.text;
    telefonoInicial = telefonoController.text;
    documentoInicial = documentoController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Campos de texto
            _buildTextField('Nombre', nombreController),
            const SizedBox(height: 16),
            _buildTextField('Apellido', apellidoController),
            const SizedBox(height: 16),
            _buildTextField('Correo Electrónico', correoController),
            const SizedBox(height: 16),
            _buildTextField('Teléfono', telefonoController),
            const SizedBox(height: 16),
            _buildTextField('Documento de Identidad', documentoController),
            const SizedBox(height: 32),

            // Botones de acción
            Center(
              child: isEditing
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _guardarCambios,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Guardar Cambios'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _cancelarEdicion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ],
              )
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Actualizar Información'),
              ),
            ),
            const SizedBox(height: 16),

            // Botón de Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.signIn, (route) => false);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Cerrar Sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para campos de texto
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Función para guardar cambios
  void _guardarCambios() {
    setState(() {
      isEditing = false;
      // Actualiza valores iniciales con los nuevos datos
      nombreInicial = nombreController.text;
      apellidoInicial = apellidoController.text;
      correoInicial = correoController.text;
      telefonoInicial = telefonoController.text;
      documentoInicial = documentoController.text;

      // Muestra un SnackBar de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Función para cancelar edición y restaurar valores iniciales
  void _cancelarEdicion() {
    setState(() {
      isEditing = false;

      // Restaura los valores originales
      nombreController.text = nombreInicial;
      apellidoController.text = apellidoInicial;
      correoController.text = correoInicial;
      telefonoController.text = telefonoInicial;
      documentoController.text = documentoInicial;
    });
  }
}

