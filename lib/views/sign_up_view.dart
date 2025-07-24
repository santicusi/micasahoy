import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/field_definition.dart';
import '../widgets/field_factory.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final String baseUrl = 'https://minciencias-strapi.onrender.com';
  List<FieldDefinition> campos = [];
  Map<String, dynamic> valores = {};
  Map<String, String?> errores = {};
  bool isLoading = true;
  bool isSubmitting = false;

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

  @override
  void initState() {
    super.initState();
    cargarCampos();
  }

  Future<void> cargarCampos() async {
    try {
      final response = await http.get(Uri.parse(
        '$baseUrl/api/formularios?filters[identificador][\$eq]=formulario-registro-usuarios&populate=entradas',
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📦 Respuesta completa del formulario: ${response.body}');

        final entradas = data['data'][0]['attributes']['entradas'] as List?;

        if (entradas == null || entradas.isEmpty) {
          print('⚠️ No se encontraron entradas en el formulario');
          setState(() => isLoading = false);
          return;
        }

        print('📝 Entradas del formulario: $entradas');

        final definiciones = entradas
            .map((e) {
          print('🔍 Procesando entrada: $e');
          return FieldDefinition.fromJson(e);
        })
            .where((f) => f.identifier != null && f.identifier!.isNotEmpty)
            .toList();

        print('✅ Campos procesados: ${definiciones.length}');
        for (var campo in definiciones) {
          print('🏷️ Campo: ${campo.identifier} - Título: ${campo.title} - Tipo: ${campo.type} - Requerido: ${campo.required}');
        }

        setState(() {
          campos = definiciones;
          // Inicializar valores con defaults
          for (var campo in campos) {
            valores[campo.identifier!] = campo.context?['defaultValue'];
          }
          isLoading = false;
        });
      } else {
        print('❌ Error al cargar formulario: ${response.statusCode} - ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Excepción al cargar campos: $e');
      setState(() => isLoading = false);
    }
  }

  bool validarFormulario() {
    errores.clear();
    bool esValido = true;

    for (var campo in campos) {
      if (campo.required == true) {
        final valor = valores[campo.identifier];
        if (valor == null ||
            (valor is String && valor.trim().isEmpty) ||
            (valor is List && valor.isEmpty)) {
          errores[campo.identifier!] = 'Este campo es obligatorio';
          esValido = false;
        }
      }
    }

    setState(() {});
    return esValido;
  }

  Future<void> enviarFormulario() async {
    if (!validarFormulario()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, completa todos los campos obligatorios'),
          backgroundColor: darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final body = valores.map((key, value) {
      if (value is DateTime) {
        return MapEntry(key, value.toIso8601String());
      }
      return MapEntry(key, value);
    });

    print('📤 Enviando datos: $body');

    final url = Uri.parse('$baseUrl/api/auth/local/register');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Respuesta del servidor: ${response.statusCode} - ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cuenta creada correctamente.'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context);
      } else {
        final error = data['error']?['message'] ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('❌ Excepción al enviar formulario: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Widget buildFieldLabel(FieldDefinition campo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            campo.title ?? campo.identifier ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: darkBrown,
            ),
          ),
          if (campo.required == true) ...[
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryRed,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildFieldHelp(FieldDefinition campo) {
    if (campo.help == null || campo.help!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              campo.help!,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldError(String? fieldId) {
    final error = errores[fieldId];
    if (error == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: primaryRed,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: primaryRed,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: pureWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: darkBrown,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crear Cuenta',
          style: TextStyle(
            color: darkBrown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: primaryGreen,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando formulario...',
              style: TextStyle(
                color: primaryBrown,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header con logo y descripción
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGreen.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Título
                    Text(
                      'Registro de Usuario',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Descripción
                    Text(
                      'Completa la información para crear tu cuenta en el sistema de registro de predios',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryBrown,
                        height: 1.4,
                      ),
                    ),

                    // Línea decorativa
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      height: 1,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentGold.withOpacity(0.3),
                            accentGold,
                            accentGold.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Formulario dinámico
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de la sección
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Información Personal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),

                    // Leyenda de campos obligatorios
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 20),
                      child: Row(
                        children: [
                          Text(
                            '*',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryRed,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Campos obligatorios',
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Debug: mostrar cantidad de campos
                    if (campos.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accentGold.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber, color: darkGold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No se pudieron cargar los campos del formulario. Verifica la conexión.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: darkBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Campos dinámicos
                      ...campos.where((campo) => campo.hide != true).map((campo) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label del campo
                              buildFieldLabel(campo),

                              // Campo input
                              Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme: InputDecorationTheme(
                                    hintStyle: TextStyle(
                                      color: textSecondary.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: errores.containsKey(campo.identifier)
                                              ? primaryRed
                                              : lightGrey,
                                          width: 1.5
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: errores.containsKey(campo.identifier)
                                              ? primaryRed
                                              : lightGrey,
                                          width: 1.5
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: errores.containsKey(campo.identifier)
                                              ? primaryRed
                                              : primaryGreen,
                                          width: 2
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: darkRed, width: 1.5),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: darkRed, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: pureWhite,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                                child: FieldFactory.build(
                                  campo,
                                      (value) {
                                    setState(() {
                                      valores[campo.identifier!] = value;
                                      // Limpiar error cuando el usuario modifica el campo
                                      if (errores.containsKey(campo.identifier)) {
                                        errores.remove(campo.identifier);
                                      }
                                    });
                                  },
                                  initialValue: valores[campo.identifier],
                                ),
                              ),

                              // Texto de ayuda
                              buildFieldHelp(campo),

                              // Mensaje de error
                              buildFieldError(campo.identifier),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botón de crear cuenta
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (isSubmitting || campos.isEmpty) ? null : enviarFormulario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: pureWhite,
                    disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                    elevation: 4,
                    shadowColor: primaryGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    overlayColor: WidgetStateProperty.all(
                      darkGreen.withOpacity(0.1),
                    ),
                  ),
                  child: isSubmitting
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: pureWhite,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Creando cuenta...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 16),

              // Link de regreso al login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '¿Ya tienes cuenta? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryBrown,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryRed,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Inicia sesión',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

