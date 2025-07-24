import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaFecha extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<DateTime> onChanged;
  final DateTime? initialValue;
  final bool enabled;


  const EntradaFecha({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  State<EntradaFecha> createState() => _EntradaFechaState();
}

class _EntradaFechaState extends State<EntradaFecha> {
  late DateTime _selectedDate;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialValue ??
        DateTime.tryParse(widget.def.context['defaultValue'] ?? '') ??
        DateTime.now();

    _controller = TextEditingController(
      text: _formatearFecha(_selectedDate),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.year.toString().padLeft(4, '0')}-"
        "${fecha.month.toString().padLeft(2, '0')}-"
        "${fecha.day.toString().padLeft(2, '0')}";
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _formatearFecha(picked);
      });
      widget.onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: widget.def.title,
          enabled: widget.enabled,
          border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      validator: widget.def.required
          ? (value) =>
      (value == null || value.isEmpty) ? 'Campo requerido' : null
          : null,
      onTap: _seleccionarFecha,
    );
  }
}


