import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/field_definition.dart';

class EntradaNumero extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<num> onChanged;
  final dynamic initialValue;
  final bool enabled;


  const EntradaNumero({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  State<EntradaNumero> createState() => _EntradaNumeroState();
}

class _EntradaNumeroState extends State<EntradaNumero>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final valorInicial = widget.initialValue?.toString() ??
        widget.def.context['defaultValue']?.toString() ??
        '';
    _controller = TextEditingController(text: valorInicial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final min = widget.def.context['min'] as num?;
    final max = widget.def.context['max'] as num?;
    final isReal = (widget.def.context['type'] as String?) == 'real';

    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Ingrese un número...',
          enabled: widget.enabled,
          border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: isReal,
        signed: false,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(isReal ? r'\d+(\.\d*)?' : r'\d+'),
        ),
      ],
      validator: (v) {
        if (widget.def.required && (v == null || v.isEmpty)) {
          return 'Requerido';
        }
        final n = num.tryParse(v!);
        if (n == null) return 'Número inválido';
        if (min != null && n < min) return 'Mínimo $min';
        if (max != null && n > max) return 'Máximo $max';
        return null;
      },
      onChanged: (v) {
        final n = num.tryParse(v) ?? 0;
        widget.onChanged(n);
      },
    );
  }
}

