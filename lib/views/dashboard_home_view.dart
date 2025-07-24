import 'package:booking_system_flutter/views/pantalla_detalle_predio.dart';
import 'package:booking_system_flutter/views/pantalla_registro_predios.dart';
import 'package:flutter/material.dart';
import 'package:booking_system_flutter/views/pantalla_enviado_view.dart';
import 'package:booking_system_flutter/views/pantalla_perfil_view.dart';
import 'package:booking_system_flutter/strapi_service.dart';
import 'package:http/http.dart' as http;
import 'package:booking_system_flutter/data/municipios_colombia.dart';
import 'dart:convert';

import '../data/departamentos_colombia.dart';
import '../models/field_definition.dart';
import '../widgets/field_factory.dart';

class DashboardHomeView extends StatefulWidget {
  final int initialIndex;

  const DashboardHomeView({super.key, this.initialIndex = 0});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  late int _selectedIndex;

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
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeSection(),
    const PantallaEnviadoView(),
    const PantallaPerfilView(),
  ];

  final List<String> _titles = [
    '¡Bienvenido de nuevo!',
    'Estado del Predio',
    'Perfil del Propietario',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: pureWhite,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(
            color: darkBrown,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: darkBrown,
          selectedItemColor: primaryGreen,
          unselectedItemColor: lightGrey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_upload_outlined),
              activeIcon: Icon(Icons.cloud_upload),
              label: 'Enviados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// Sección de Inicio: Lista de Predios
class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final StrapiService strapiService = StrapiService();
  List<dynamic> predios = [];
  bool isLoading = true;

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
    fetchPredios();
  }

  Future<void> fetchPredios() async {
    try {
      final profile = await strapiService.getUserProfile();
      final propietarioId = profile?['id'].toString() ?? '';
      if (propietarioId.isEmpty) throw Exception('No hay propietario logueado');

      final data = await strapiService.getPrediosPropietario(propietarioId);

      setState(() {
        predios = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _mostrarFormularioLevantamiento(int predioId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            builder: (_, controller) {
              return FutureBuilder(
                future: strapiService.getFormularioLevantamiento(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryGreen),
                    );
                  }
                  if (!snapshot.hasData || snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error al cargar el formulario.',
                        style: TextStyle(color: darkRed),
                      ),
                    );
                  }

                  final form = snapshot.data!;
                  final entradas = List<Map<String, dynamic>>.from(form['entradas']);
                  final formKey = GlobalKey<FormState>();
                  final Map<String, dynamic> formData = {};

                  void onChanged(String id, dynamic val) => formData[id] = val;

                  Future<void> submit() async {
                    if (!formKey.currentState!.validate()) return;
                    final profile = await strapiService.getUserProfile();
                    final cr_interesado = profile?['id'];

                    final entries = entradas.map((e) {
                      final id = e['identifier'];
                      return {
                        'valor': formData[id]?.toString() ?? '',
                        'identifier': id,
                        'title': e['title'],
                        'help': e['help'],
                        'type': e['type'],
                        'required': e['required'],
                        'hide': e['hide'],
                        'context': e['context'] ?? {},
                      };
                    }).toList();

                    final body = {
                      'data': {
                        'cr_interesado': cr_interesado,
                        'cr_predio': predioId,
                        'entries': entries,
                      }
                    };

                    final uri = Uri.parse('${strapiService.baseUrl}/solicitudes/bulk-create');
                    final headers = await strapiService.getHeaders();
                    final response = await http.post(uri, headers: headers, body: jsonEncode(body));

                    final ok = response.statusCode == 200 || response.statusCode == 201;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Formulario enviado' : 'Error al enviar formulario'),
                        backgroundColor: ok ? primaryGreen : darkRed,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: ListView(
                        controller: controller,
                        children: [
                          // Header del modal
                          Row(
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
                              const Text(
                                'Formulario de Levantamiento',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: darkBrown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ...entradas.map((e) => Column(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme: _getCustomInputDecoration(),
                                ),
                                child: FieldFactory.build(
                                  FieldDefinition.fromJson(e),
                                      (v) => onChanged(e['identifier'], v),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          )),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: pureWhite,
                                elevation: 4,
                                shadowColor: primaryGreen.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Enviar Formulario',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _mostrarFormularioPredio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            builder: (_, controller) {
              return FutureBuilder(
                future: strapiService.getFormDefinition('predio'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryGreen),
                    );
                  }
                  if (!snapshot.hasData || snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error al cargar el formulario.',
                        style: TextStyle(color: darkRed),
                      ),
                    );
                  }

                  final json = snapshot.data as Map<String, dynamic>;
                  final puntoFinal = json['punto_final'];
                  final raw = List<Map<String, dynamic>>.from(json['entradas']);
                  final fields = raw.map((e) => FieldDefinition.fromJson(Map<String, dynamic>.from(e))).toList();

                  final formData = <String, dynamic>{};
                  final formKey = GlobalKey<FormState>();

                  void onFieldChanged(String id, dynamic value) {
                    formData[id] = value;
                  }

                  Future<void> submit() async {
                    if (!formKey.currentState!.validate()) return;
                    final profile = await strapiService.getUserProfile();
                    formData['interesado_cr_interesado'] = profile?['id'];

                    if (!formData.containsKey('unidad') || formData['unidad'] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Debes seleccionar la Unidad del predio'),
                          backgroundColor: darkRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      return;
                    }

                    final ok = await strapiService.submitForm(puntoFinal, formData);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? 'Predio registrado correctamente' : 'Error al guardar'),
                        backgroundColor: ok ? primaryGreen : darkRed,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    if (ok) {
                      Navigator.of(context).pop();
                      await fetchPredios();

                      final nuevoPredio = await strapiService.getPrediosPropietario(profile!['id'].toString());

                      if (nuevoPredio.isNotEmpty && nuevoPredio.last != null) {
                        final idNuevoPredio = nuevoPredio.last['id'];
                        _mostrarFormularioLevantamiento(idNuevoPredio);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('No se pudo identificar el nuevo predio.'),
                            backgroundColor: darkRed,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: formKey,
                      child: ListView(
                        controller: controller,
                        children: [
                          // Header del modal
                          Row(
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
                              const Text(
                                'Registrar Predio',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: darkBrown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          ...fields.map((f) => Column(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  inputDecorationTheme: _getCustomInputDecoration(),
                                ),
                                child: FieldFactory.build(f, (v) => onFieldChanged(f.identifier, v)),
                              ),
                              const SizedBox(height: 16),
                            ],
                          )),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: pureWhite,
                                elevation: 4,
                                shadowColor: primaryGreen.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Guardar Predio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con estadísticas
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Predios Registrados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${predios.length}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'propiedades activas',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: primaryGreen,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

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
                'Mis Propiedades',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de predios
          isLoading
              ? const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: primaryGreen),
            ),
          )
              : predios.isEmpty
              ? Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_work_outlined,
                    size: 64,
                    color: primaryBrown.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay predios registrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryBrown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra tu primer predio para comenzar',
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _mostrarFormularioPredio,
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Registrar Predio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: pureWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              : Expanded(
            child: RefreshIndicator(
              onRefresh: fetchPredios,
              color: primaryGreen,
              child: ListView.builder(
                itemCount: predios.length,
                itemBuilder: (context, index) {
                  final relacion = predios[index]['attributes'];
                  final predio = relacion['cr_predio']?['data']?['attributes'] ?? {};
                  final predioId = relacion['unidad']?['data']?['id'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                    child: Builder(
                      builder: (_) {
                        final unidad = relacion['unidad']?['data']?['attributes'];

                        final codigoDepartamento = unidad?['departamento']?.toString().padLeft(2, '0');
                        final codigoMunicipio = unidad?['municipio']?.toString().padLeft(3, '0');

                        final nombreDepartamento = departamentosColombia[codigoDepartamento] ?? 'Departamento desconocido';
                        final nombreMunicipio = municipiosColombia[codigoMunicipio] ?? 'Municipio desconocido';

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final unidadData = relacion['unidad']?['data'];
                              if (unidadData != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PantallaDetallePredio(
                                      predio: unidadData['attributes'],
                                      idPredioReal: unidadData['id'],
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('No se pudo acceder al predio.'),
                                    backgroundColor: darkRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: primaryGreen,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Predio: ${unidad?['numero_predial_nacional'] ?? 'Sin número'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: darkBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.place_outlined,
                                              size: 14,
                                              color: textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '$nombreDepartamento, $nombreMunicipio',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: primaryBrown,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

