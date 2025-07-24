import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaPassword extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final bool enabled;


  const EntradaPassword({
    super.key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  });

  @override
  State<EntradaPassword> createState() => _EntradaPasswordState();
}

class _EntradaPasswordState extends State<EntradaPassword>
    with AutomaticKeepAliveClientMixin {
  bool obscure = true;
  late TextEditingController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🟢 importante para AutomaticKeepAlive

    final min = widget.def.context['minCharacters'] ?? 0;
    final max = widget.def.context['maxCharacters'] ?? 100;
    final regex = widget.def.context['regex'];

    return TextFormField(
      controller: _controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: widget.def.title,
        helperText: widget.def.help,
          enabled: widget.enabled,
          border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => obscure = !obscure),
        ),
      ),
      maxLength: max,
      keyboardType: TextInputType.text,
      onChanged: widget.onChanged,
      validator: (value) {
        if (widget.def.required && (value == null || value.isEmpty)) {
          return 'Campo requerido';
        }
        if (value != null && value.length < min) {
          return 'Debe tener al menos $min caracteres';
        }
        if (regex != null) {
          final regExp = RegExp(regex);
          if (!regExp.hasMatch(value!)) {
            return 'Formato inválido';
          }
        }
        return null;
      },
    );
  }
}

