import 'package:flutter/material.dart';
import 'package:booking_system_flutter/routes/routes.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores para los campos del formulario
    final TextEditingController nameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController contactNumberController = TextEditingController();
    final TextEditingController documentNumberController = TextEditingController();

    // Variables para el tipo de documento
    final List<String> documentTypes = ['Cédula', 'Pasaporte', 'Otro'];
    String? selectedDocumentType;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea tu cuenta'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo: Nombre
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Apellido
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Correo
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Contraseña
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Número de contacto
            TextField(
              controller: contactNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de contacto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Tipo de documento
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de documento',
                border: OutlineInputBorder(),
              ),
              value: selectedDocumentType,
              items: documentTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                selectedDocumentType = value;
              },
            ),
            const SizedBox(height: 16),

            // Campo: Número de documento
            TextField(
              controller: documentNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de documento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Botón: Crear cuenta
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí agregarás la lógica para validar y registrar la cuenta
                  // Por ahora, solo navega a la pantalla de inicio de sesión
                  Navigator.pushNamed(context, AppRoutes.signIn);
                },
                child: const Text('Crear cuenta'),
              ),
            ),
            const SizedBox(height: 16),

            // Enlace: ¿Ya tienes cuenta? Iniciar sesión
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signIn);
                },
                child: const Text(
                  '¿Ya tienes cuenta? Iniciar sesión',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
