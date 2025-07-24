import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaDireccion extends StatelessWidget {
  final FieldDefinition def;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final bool enabled;


  const EntradaDireccion({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: def.title,
        hintText: def.context['placeholder'] as String? ?? '',
        border: const OutlineInputBorder(),
      ),
      initialValue: initialValue ?? def.context['defaultValue'] as String? ?? '', // ✅ CAMBIO
      validator: def.required
          ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null
          : null,
      onChanged: onChanged,
    );
  }
}

