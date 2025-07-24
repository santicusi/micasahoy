import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaRadio extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<dynamic> onChanged;
  final dynamic initialValue;
  final bool enabled;


  const EntradaRadio({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  State<EntradaRadio> createState() => _EntradaRadioState();
}

class _EntradaRadioState extends State<EntradaRadio>
    with AutomaticKeepAliveClientMixin {
  dynamic selectedValue;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue ??
        widget.def.context['defaultValue']; // Opcional
  }

  void _handleChange(dynamic value) {
    setState(() => selectedValue = value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final options = List<Map<String, dynamic>>.from(
      widget.def.context['options'] as List? ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((opt) {
          final nombre = opt['label']?.toString() ?? 'Opción';
          final valor = opt['value'];

          return RadioListTile(
            title: Text(nombre),
            value: valor,
            groupValue: selectedValue,
            onChanged: _handleChange,
          );
        }).toList(),
      ],
    );
  }
}

