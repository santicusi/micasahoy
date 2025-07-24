import 'package:flutter/material.dart';
import '../models/field_definition.dart';
import '../widgets/field_factory.dart';
import '../strapi_service.dart';

class PantallaRegistroPredio extends StatefulWidget {
  const PantallaRegistroPredio({super.key});

  @override
  State<PantallaRegistroPredio> createState() => _PantallaRegistroPredioState();
}

class _PantallaRegistroPredioState extends State<PantallaRegistroPredio> {
  final StrapiService strapiService = StrapiService();
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> formData = {};
  bool isLoading = true;
  List<FieldDefinition> fields = [];

  @override
  void initState() {
    super.initState();
    _cargarFormulario();
  }

  Future<void> _cargarFormulario() async {
    try {
      final definicion = await strapiService.getFormDefinition('registro-predio');
      if (definicion == null) {
        return;
      }
      final entradas = List<Map<String, dynamic>>.from(definicion['entradas']);
      setState(() {
        fields = entradas.map((e) => FieldDefinition.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (e) {
    }
  }

  Future<void> _guardarPredio() async {
    if (!formKey.currentState!.validate()) return;
    final profile = await strapiService.getUserProfile();
    final userId = profile?['id'];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el usuario.')),
      );
      return;
    }

    formData['interesado_cr_interesado'] = userId;

    if (!formData.containsKey('unidad') || formData['unidad'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar la Unidad del predio')),
      );
      return;
    }


    final nuevoId = await strapiService.crearPredio(formData);

    if (nuevoId != null) {
      Navigator.of(context).pop(nuevoId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar el predio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Predio')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              ...fields.map((f) => Column(
                children: [
                  FieldFactory.build(f, (val) {
                    formData[f.identifier] = val;
                  }),
                  const SizedBox(height: 16),
                ],
              )),
              ElevatedButton(
                onPressed: _guardarPredio,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
