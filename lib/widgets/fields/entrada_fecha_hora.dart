import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaFechaHora extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<DateTime> onChanged;
  final DateTime? initialValue; // ✅ NUEVO
  final bool enabled;


  const EntradaFechaHora({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue, // ✅ NUEVO
    required this.enabled,
  }) : super(key: key);

  @override
  State<EntradaFechaHora> createState() => _EntradaFechaHoraState();
}

class _EntradaFechaHoraState extends State<EntradaFechaHora> {
  late DateTime selectedDateTime;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    selectedDateTime = widget.initialValue ??
        DateTime.tryParse(widget.def.context['defaultValue'] ?? '') ??
        DateTime.now();

    _controller = TextEditingController(
      text: selectedDateTime.toLocal().toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.def.title,
          enabled: widget.enabled,
          border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.schedule),
      ),
      readOnly: true,
      validator: widget.def.required
          ? (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null
          : null,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDateTime,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date == null) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );
        if (time != null) {
          final newDT = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          setState(() {
            selectedDateTime = newDT;
            _controller.text = newDT.toLocal().toIso8601String();
          });
          widget.onChanged(newDT);
        }
      },
    );
  }
}
