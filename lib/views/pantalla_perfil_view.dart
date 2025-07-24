import 'package:flutter/material.dart';
import 'package:booking_system_flutter/strapi_service.dart';
import '../models/field_definition.dart';
import '../widgets/field_factory.dart';
import 'sign_in_view.dart';

class PantallaPerfilView extends StatefulWidget {
  const PantallaPerfilView({super.key});

  @override
  State<PantallaPerfilView> createState() => _PantallaPerfilViewState();
}

class _PantallaPerfilViewState extends State<PantallaPerfilView> {
  final StrapiService strapiService = StrapiService();
  Map<String, dynamic> userProfile = {};
  List<FieldDefinition> definiciones = [];
  Map<String, String?> errores = {};
  bool isLoading = true;
  bool isSaving = false;
  bool isEditing = false;

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
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => isLoading = true);

    try {
      final perfil = await strapiService.getUserProfile();
      final definicionesCampos = await strapiService.getDefinicionesCamposPerfil();

      print('📦 Perfil del usuario: $perfil');
      print('📝 Definiciones de campos: ${definicionesCampos.length}');

      for (var def in definicionesCampos) {
        print('🏷️ Campo perfil: ${def.identifier} - Título: ${def.title} - Tipo: ${def.type} - Requerido: ${def.required}');
      }

      if (perfil != null && definicionesCampos.isNotEmpty) {
        setState(() {
          userProfile = perfil;
          definiciones = definicionesCampos;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        mostrarError('No se pudo cargar el perfil o los campos del formulario.');
      }
    } catch (e) {
      print('❌ Error al cargar datos del perfil: $e');
      setState(() => isLoading = false);
      mostrarError('Error al cargar los datos: $e');
    }
  }

  bool validarFormulario() {
    errores.clear();
    bool esValido = true;

    for (var def in definiciones) {
      if (def.required == true) {
        final valor = userProfile[def.identifier];
        if (valor == null ||
            (valor is String && valor.trim().isEmpty) ||
            (valor is List && valor.isEmpty)) {
          errores[def.identifier!] = 'Este campo es obligatorio';
          esValido = false;
        }
      }
    }

    setState(() {});
    return esValido;
  }

  void mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: darkRed, size: 24),
            const SizedBox(width: 12),
            Text(
              'Error',
              style: TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          mensaje,
          style: TextStyle(
            color: primaryBrown,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> guardarCambios() async {
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

    setState(() => isSaving = true);

    final Map<String, dynamic> datosActualizados = {};
    for (var def in definiciones) {
      datosActualizados[def.identifier!] = userProfile[def.identifier];
    }

    print('📤 Enviando datos actualizados: $datosActualizados');

    final resultado = await strapiService.actualizarCamposUsuario(datosActualizados);

    setState(() => isSaving = false);

    if (resultado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado correctamente'),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() {
        isEditing = false;
        errores.clear();
      });
      await cargarDatos();
    } else {
      mostrarError('No se pudo guardar los cambios.');
    }
  }

  Future<void> cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: pureWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.logout, color: darkRed, size: 24),
            const SizedBox(width: 12),
            Text(
              'Cerrar Sesión',
              style: TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(
            color: primaryBrown,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: primaryBrown,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: darkRed,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await strapiService.deleteToken();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInView()),
              (_) => false,
        );
      }
    }
  }

  Widget buildFieldWidget(FieldDefinition field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: field.required == true ? primaryRed.withOpacity(0.3) : lightGrey.withOpacity(0.5),
          width: field.required == true ? 2 : 1,
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
                    color: field.required == true ? primaryRed : primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    field.title ?? field.identifier ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: darkBrown,
                      height: 1.4,
                    ),
                  ),
                ),
                if (field.required == true)
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
                isEditing
                    ? (valor) {
                  setState(() {
                    userProfile[field.identifier!] = valor;
                    // Limpiar error cuando el usuario modifica el campo
                    if (errores.containsKey(field.identifier)) {
                      errores.remove(field.identifier);
                    }
                  });
                }
                    : (_) {},
                initialValue: userProfile[field.identifier],
                enabled: isEditing,
              ),
            ),

            // Mensaje de error
            if (errores.containsKey(field.identifier)) ...[
              const SizedBox(height: 8),
              Row(
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
                      errores[field.identifier]!,
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryRed,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecorationTheme _getCustomInputDecoration() {
    return InputDecorationTheme(
      hintStyle: TextStyle(
        color: textSecondary.withOpacity(0.6),
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightGrey.withOpacity(0.5), width: 1),
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
                  '$cantidadCampos ${cantidadCampos == 1 ? 'campo' : 'campos'}',
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
    if (isLoading) {
      return Scaffold(
        backgroundColor: backgroundGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: primaryGreen,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Cargando perfil...',
                style: TextStyle(
                  color: primaryBrown,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Separar campos obligatorios y opcionales
    final camposObligatorios = definiciones.where((f) => f.required == true).toList();
    final camposOpcionales = definiciones.where((f) => f.required != true).toList();

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: cargarDatos,
            color: primaryGreen,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header del perfil
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryGreen,
                        darkGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: pureWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.person,
                          color: pureWhite,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mi Perfil',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: pureWhite,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Administra tu información personal',
                              style: TextStyle(
                                fontSize: 14,
                                color: pureWhite.withOpacity(0.9),
                              ),
                            ),
                            if (isEditing) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: primaryRed.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${camposObligatorios.length} obligatorios',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: pureWhite,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: pureWhite.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${camposOpcionales.length} opcionales',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: pureWhite,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: pureWhite.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                              if (!isEditing) {
                                errores.clear();
                              }
                            });
                          },
                          icon: Icon(
                            isEditing ? Icons.close : Icons.edit,
                            color: pureWhite,
                            size: 18,
                          ),
                          label: Text(
                            isEditing ? 'Cancelar' : 'Editar',
                            style: TextStyle(
                              color: pureWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Debug: mostrar cantidad de campos
                if (definiciones.isEmpty) ...[
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
                            'No se pudieron cargar los campos del perfil. Verifica la configuración en Strapi.',
                            style: TextStyle(
                              fontSize: 14,
                              color: darkBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Sección de campos obligatorios
                if (camposObligatorios.isNotEmpty && isEditing) ...[
                  _buildSectionHeader(
                    'Campos Obligatorios',
                    Icons.priority_high,
                    primaryRed,
                    camposObligatorios.length,
                  ),
                  ...camposObligatorios.map((field) => buildFieldWidget(field)),
                  const SizedBox(height: 24),
                ],

                // Sección de campos opcionales o todos los campos si no está editando
                if ((camposOpcionales.isNotEmpty && isEditing) || (!isEditing && definiciones.isNotEmpty)) ...[
                  if (isEditing)
                    _buildSectionHeader(
                      'Campos Opcionales',
                      Icons.info_outline,
                      primaryGreen,
                      camposOpcionales.length,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Información Personal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isEditing)
                    ...camposOpcionales.map((field) => buildFieldWidget(field))
                  else
                    ...definiciones.map((field) => buildFieldWidget(field)),
                ],

                const SizedBox(height: 24),

                // Botones de acción
                if (isEditing) ...[
                  // Información antes de guardar
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
                          Icons.save_outlined,
                          color: darkGold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Revisa toda la información antes de guardar. Los campos marcados como obligatorios deben ser completados.',
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
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : guardarCambios,
                      icon: isSaving
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: pureWhite,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isSaving ? 'Guardando cambios...' : 'Guardar Cambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaving ? primaryGreen.withOpacity(0.6) : primaryGreen,
                        foregroundColor: pureWhite,
                        elevation: 4,
                        shadowColor: primaryGreen.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Sección de configuración
                Container(
                  padding: const EdgeInsets.all(24),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primaryRed,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Configuración',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Información de seguridad
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryRed.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryRed.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: primaryRed,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Al cerrar sesión se eliminará tu información local y deberás iniciar sesión nuevamente.',
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

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: cerrarSesion,
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: darkRed,
                            side: BorderSide(color: darkRed, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Overlay de guardando
          if (isSaving)
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
                        'Guardando cambios...',
                        style: TextStyle(
                          color: primaryBrown,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}