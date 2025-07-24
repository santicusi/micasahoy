import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaBoolean extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<bool> onChanged;
  final bool? initialValue;
  final bool enabled;

  const EntradaBoolean({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  State<EntradaBoolean> createState() => _EntradaBooleanState();
}

class _EntradaBooleanState extends State<EntradaBoolean>
    with AutomaticKeepAliveClientMixin {
  late bool valor;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    valor = widget.initialValue ?? (widget.def.context['defaultValue'] == true);
    print('🟢 initState - ${widget.def.identifier} - valor: $valor');
  }

  @override
  void didUpdateWidget(covariant EntradaBoolean oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nuevo = widget.initialValue ?? false;
    if (valor != nuevo) {
      setState(() => valor = nuevo);
      print('🔁 didUpdateWidget - ${widget.def.identifier} - actualizado a: $valor');
    }
  }

  void _cambiarValor(bool nuevoValor) {
    setState(() => valor = nuevoValor);
    widget.onChanged(nuevoValor);
    print('✅ Cambiado - ${widget.def.identifier} - nuevo valor: $nuevoValor');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // necesario para AutomaticKeepAlive
    print('🧱 build - ${widget.def.identifier} - valor: $valor');

    return Switch(
      value: valor,
      onChanged: widget.enabled ? _cambiarValor : null,
    );
  }
}



