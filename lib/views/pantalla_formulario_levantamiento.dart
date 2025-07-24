import 'package:flutter/material.dart';
import 'package:booking_system_flutter/strapi_service.dart';
import 'package:booking_system_flutter/models/field_definition.dart';
import 'package:booking_system_flutter/widgets/field_factory.dart';
import 'dart:convert';

class PantallaFormularioLevantamiento extends StatefulWidget {
  final int interesadoId;

  const PantallaFormularioLevantamiento({super.key, required this.interesadoId});

  @override
  State<PantallaFormularioLevantamiento> createState() => _PantallaFormularioLevantamientoState();
}

bool isLoading = false;

class _PantallaFormularioLevantamientoState extends State<PantallaFormularioLevantamiento> {
  final StrapiService strapiService = StrapiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {};

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

  Future<void> _enviarFormulario(List<FieldDefinition> campos, String endpoint) async {
    if (!formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final profile = await strapiService.getUserProfile();
      final crInteresado = profile?['id'];

      // 🔁 1. Subir archivos y reemplazar su valor en formData por el ID de respuesta
      for (var f in campos) {
        if (f.type == 'file' && formData[f.identifier] != null) {
          final filePath = formData[f.identifier].toString();
          final uploadResponse = await strapiService.subirArchivo(filePath);
          if (uploadResponse != null && uploadResponse.isNotEmpty) {
            final relativeUrl = uploadResponse[0]['url'];
            final fullUrl = '${strapiService.baseUrl.replaceFirst('/api', '')}$relativeUrl';
            formData[f.identifier] = fullUrl; // ← ahora `valor` será la URL completa
          } else {
            print('❌ Error al subir el archivo: $filePath');
          }
        }
      }

      // ✅ 2. Crear la estructura de entradas con los valores ya procesados
      final entries = campos.map((f) {
        dynamic valor = formData[f.identifier];

        // Si es un Map (datos geométricos), convertir a JSON string
        if (valor is Map<String, dynamic>) {
          valor = jsonEncode(valor); // ← Esto genera JSON válido con comillas
        }

        return {
          'valor': valor?.toString() ?? '',
          'identifier': f.identifier,
          'title': f.title,
          'help': f.help,
          'type': f.type,
          'required': f.required,
          'hide': f.hide,
          'context': f.context,
        };
      }).toList();

      final body = {
        'data': {
          'cr_interesado': crInteresado,
          'cr_predio': widget.interesadoId,
          'entries': entries,
        }
      };

      final headers = await strapiService.getHeaders();
      final uri = Uri.parse('${strapiService.baseUrl.replaceFirst('/api', '')}$endpoint');
      final res = await strapiService.post(uri, headers: headers, body: body);

      if (!mounted) return;

      if (res) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Formulario enviado correctamente'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        // 👉 Regresa al Dashboard y recarga
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard',
              (route) => false,
          arguments: {'tab': 1}, // Enviados es el tab 1
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al enviar el formulario'),
            backgroundColor: darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildFieldWidget(FieldDefinition field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: field.required ? primaryRed.withOpacity(0.3) : lightGrey.withOpacity(0.5),
          width: field.required ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la pregunta
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: field.required ? primaryRed : primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    field.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkBrown,
                      height: 1.4,
                    ),
                  ),
                ),
                if (field.required)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryRed.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: primaryRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OBLIGATORIO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: primaryRed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Texto de ayuda (help)
            if (field.help != null && field.help!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentGold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentGold.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: darkGold,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        field.help!,
                        style: TextStyle(
                          fontSize: 13,
                          color: primaryBrown,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Campo de entrada con tema personalizado
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: _getCustomInputDecoration(),
              ),
              child: FieldFactory.build(
                field,
                    (v) => formData[field.identifier] = v,
                predioId: widget.interesadoId,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecorationTheme _getCustomInputDecoration() {
    return InputDecorationTheme(
      labelStyle: TextStyle(
        color: primaryBrown.withOpacity(0.8),
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightGrey, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightGrey, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryGreen, width: 2),
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
    );
  }

  Widget _buildSectionHeader(String titulo, IconData icono, Color color, int cantidadCampos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color == primaryRed ? darkRed : darkGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: pureWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cantidadCampos ${cantidadCampos == 1 ? 'campo' : 'campos'} por completar',
                  style: TextStyle(
                    fontSize: 13,
                    color: pureWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: backgroundGrey,
          appBar: AppBar(
            backgroundColor: pureWhite,
            elevation: 0,
            scrolledUnderElevation: 2,
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
              'Formulario de Levantamiento',
              style: TextStyle(
                color: darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: FutureBuilder(
            future: strapiService.getFormularioLevantamiento(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
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
                );
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: pureWhite,
                      borderRadius: BorderRadius.circular(20),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: darkRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar formulario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No se pudo cargar el formulario de levantamiento. Intenta nuevamente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final json = snapshot.data as Map<String, dynamic>;
              final puntoFinal = json['punto_final'] as String;
              final entradas = List<Map<String, dynamic>>.from(json['entradas']);
              final allFields = entradas.map((e) => FieldDefinition.fromJson(e)).toList();

              // Eliminar duplicados por identifier
              final Map<String, FieldDefinition> uniqueFields = {};
              for (var field in allFields) {
                uniqueFields[field.identifier] = field; // Si hay duplicados, se queda con el último
              }
              final fields = uniqueFields.values.toList();

              print('🔍 Campos antes de filtrar: ${allFields.length}');
              print('🔍 Campos después de filtrar: ${fields.length}');

              // 🔍 DEBUG: Verificar duplicados
              print('🔍 Total entradas recibidas: ${entradas.length}');
              print('🔍 Total fields procesados: ${fields.length}');

              // Verificar duplicados por identifier
              final Map<String, int> identifierCount = {};
              final Map<String, int> titleCount = {};

              for (var field in fields) {
                identifierCount[field.identifier] = (identifierCount[field.identifier] ?? 0) + 1;
                titleCount[field.title] = (titleCount[field.title] ?? 0) + 1;
              }

              print('🔍 Campos con identifier duplicado:');
              identifierCount.forEach((key, value) {
                if (value > 1) {
                  print('   - $key: aparece $value veces');
                }
              });

              print('🔍 Campos con title duplicado:');
              titleCount.forEach((key, value) {
                if (value > 1) {
                  print('   - $key: aparece $value veces');
                }
              });

              // Separar campos obligatorios y opcionales
              final camposObligatorios = fields.where((f) => f.required).toList();
              final camposOpcionales = fields.where((f) => !f.required).toList();

              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header informativo
                      Container(
                        padding: const EdgeInsets.all(20),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.assignment,
                                color: primaryGreen,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Levantamiento de Información',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: darkBrown,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Completa la información técnica del predio',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: primaryRed.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${camposObligatorios.length} obligatorios',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: primaryRed,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: primaryGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${camposOpcionales.length} opcionales',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: primaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sección de campos obligatorios
                      if (camposObligatorios.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Campos Obligatorios',
                          Icons.priority_high,
                          primaryRed,
                          camposObligatorios.length,
                        ),
                        ...camposObligatorios.map((field) => _buildFieldWidget(field)),
                        const SizedBox(height: 24),
                      ],

                      // Sección de campos opcionales
                      if (camposOpcionales.isNotEmpty) ...[
                        _buildSectionHeader(
                          'Campos Opcionales',
                          Icons.info_outline,
                          primaryGreen,
                          camposOpcionales.length,
                        ),
                        ...camposOpcionales.map((field) => _buildFieldWidget(field)),
                      ],

                      const SizedBox(height: 32),

                      // Información antes del envío
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.send_outlined,
                              color: darkGold,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Revisa toda la información antes de enviar. Una vez enviado, el formulario será procesado por nuestro equipo.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: primaryBrown,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón de envío
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : () => _enviarFormulario(fields, puntoFinal),
                          icon: isLoading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: pureWhite,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.send),
                          label: Text(
                            isLoading ? 'Enviando formulario...' : 'Enviar Formulario',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLoading ? primaryGreen.withOpacity(0.6) : primaryGreen,
                            foregroundColor: pureWhite,
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
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Overlay de carga global
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.6),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: pureWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: primaryGreen,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Procesando formulario...',
                      style: TextStyle(
                        color: primaryBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Subiendo archivos y enviando datos',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}