// SOLUCIÓN 1: Modificar EntradaTexto para mantener el estado
import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaTexto extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final bool enabled;


  const EntradaTexto({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  State<EntradaTexto> createState() => _EntradaTextoState();
}

class _EntradaTextoState extends State<EntradaTexto>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;

  // ✅ Esto mantiene el widget vivo durante el scroll
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final text = widget.initialValue ?? widget.def.context['defaultValue'] as String? ?? '';
    _controller = TextEditingController(text: text);
    print('🟢 initState - ${widget.def.identifier} - text: "$text"');
  }

  @override
  void didUpdateWidget(covariant EntradaTexto oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newText = widget.initialValue ?? '';
    if (_controller.text != newText) {
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      print('🔁 didUpdateWidget - ${widget.def.identifier} - set controller.text to "$newText"');
    }
  }

  @override
  void dispose() {
    print('❌ dispose - ${widget.def.identifier}');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Importante: llamar super.build para AutomaticKeepAlive
    super.build(context);

    print('🧱 build - ${widget.def.identifier} - controller.text: "${_controller.text}"');

    final maxLen = widget.def.context['length'] as int?;
    final pattern = widget.def.context['regex'] as String?;
    final placeholder = widget.def.context['placeholder'] as String?;

    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.def.title,
        hintText: placeholder,
        border: const OutlineInputBorder(),
        enabled: widget.enabled,
        counterText: maxLen != null ? null : '',
      ),
      maxLength: maxLen,
      validator: (v) {
        if (widget.def.required && (v == null || v.isEmpty)) {
          return 'Campo requerido';
        }
        if (pattern != null && v != null && v.isNotEmpty) {
          final reg = RegExp(pattern);
          if (!reg.hasMatch(v)) {
            return 'Formato inválido';
          }
        }
        return null;
      },
      onChanged: (value) {
        widget.onChanged(value);
        print('✍️ onChanged - ${widget.def.identifier} - value: "$value"');
      },
    );
  }
}

