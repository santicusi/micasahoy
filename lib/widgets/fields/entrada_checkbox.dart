import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaCheckbox extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<List<dynamic>> onChanged;
  final List<dynamic>? initialValue;
  final bool enabled;


  const EntradaCheckbox({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  _EntradaCheckboxState createState() => _EntradaCheckboxState();
}

class _EntradaCheckboxState extends State<EntradaCheckbox>
    with AutomaticKeepAliveClientMixin {
  late List<dynamic> selected;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue != null
        ? List<dynamic>.from(widget.initialValue!)
        : widget.def.context['defaultValue'] is List
        ? List<dynamic>.from(widget.def.context['defaultValue'])
        : [];
    print('🟢 initState - ${widget.def.identifier} - selected: $selected');
  }

  @override
  void didUpdateWidget(covariant EntradaCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nuevaSeleccion = widget.initialValue ?? [];
    if (selected.toString() != nuevaSeleccion.toString()) {
      setState(() {
        selected = List<dynamic>.from(nuevaSeleccion);
      });
      print('🔁 didUpdateWidget - ${widget.def.identifier} - updated selected: $selected');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('🧱 build - ${widget.def.identifier} - selected: $selected');

    final options = List<Map<String, dynamic>>.from(
      widget.def.context['options'] as List? ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((opt) {
          final nombre = opt['label']?.toString() ?? 'Opción';
          final valor = opt['value'];

          return CheckboxListTile(
            title: Text(nombre),
            value: selected.contains(valor),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  selected.add(valor);
                } else {
                  selected.remove(valor);
                }
                widget.onChanged(List.from(selected));
                print('☑️ onChanged - ${widget.def.identifier} - selected: $selected');
              });
            },
          );
        }).toList(),
      ],
    );
  }
}


