import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/field_definition.dart';

class EntradaSelect extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<dynamic> onChanged;
  final dynamic initialValue;
  final bool enabled;


  const EntradaSelect({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  State<EntradaSelect> createState() => _EntradaSelectState();
}

class _EntradaSelectState extends State<EntradaSelect>
    with AutomaticKeepAliveClientMixin { // ← ✅ Esto mantiene el estado al hacer scroll
  List<Map<String, dynamic>> options = [];
  bool isLoading = false;
  dynamic selectedValue;
  final String baseUrl = 'https://minciencias-strapi.onrender.com';

  @override
  bool get wantKeepAlive => true; // ← ✅ Obligatorio para mantener el estado

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
    print('🟢 initState de EntradaSelect para campo: ${widget.def.identifier}');
    _loadOptions();
  }

  @override
  void didUpdateWidget(EntradaSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        selectedValue = widget.initialValue;
      });
    }
  }

  Future<void> _loadOptions() async {
    print('🚀 Iniciando _loadOptions para: ${widget.def.identifier}');
    final rawOptions = widget.def.context['options'] as List?;
    if (rawOptions != null && rawOptions.isNotEmpty) {
      setState(() {
        options = rawOptions.whereType<Map<String, dynamic>>().map((opt) {
          return {
            'label': opt['label'] ?? opt['name'] ?? 'Sin nombre',
            'value': opt['value'],
          };
        }).toList();
      });
      return;
    }

    final tableSource = widget.def.context['tableSource'] as String?;
    const posiblesCampos = ['nombre_vista', 'nombre', 'name', 'titulo'];

    if (tableSource != null) {
      setState(() => isLoading = true);
      try {
        final apiEndpoint = tableSource.replaceFirst('col-', 'col-') + 's';
        final fullUrl = '$baseUrl/api/$apiEndpoint';
        final response = await http.get(Uri.parse(fullUrl), headers: {'Content-Type': 'application/json'});

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final items = data['data'] as List? ?? [];
          setState(() {
            options = items.map((item) {
              final attributes = item['attributes'] as Map<String, dynamic>? ?? {};
              final labelKey = posiblesCampos.firstWhere((k) => attributes.containsKey(k), orElse: () => '');
              final label = labelKey.isNotEmpty ? attributes[labelKey] : 'Sin nombre';
              final value = item['id'];
              return {'label': label, 'value': value};
            }).toList();
          });
        }
      } catch (e) {
        print('💥 Error al cargar opciones: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ← ✅ Necesario para AutomaticKeepAliveClientMixin

    if (isLoading) {
      return Container(
        height: 60,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final values = options.map((e) => e['value']).toSet();
    final valueToUse = values.contains(selectedValue) ? selectedValue : null;

    return DropdownButtonFormField<dynamic>(
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Seleccione una opción...',
          enabled: widget.enabled,
          border: const OutlineInputBorder(),
      ),
      value: valueToUse,
      items: options.map((opt) {
        return DropdownMenuItem(
          value: opt['value'],
          child: Text(
            opt['label'].toString(),
            overflow: TextOverflow.ellipsis, // 👈 Evita desbordes si el texto es muy largo
          ),
        );
      }).toList(),
      onChanged: (v) {
        setState(() {
          selectedValue = v;
        });
        widget.onChanged(v);
      },
      validator: widget.def.required ? (v) => v == null ? 'Campo requerido' : null : null,
    );
  }
}
