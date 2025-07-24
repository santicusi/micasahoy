import 'package:flutter/material.dart';
import '../../models/field_definition.dart';

class EntradaSlider extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<double> onChanged;
  final double? initialValue;
  final bool enabled;


  const EntradaSlider({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  _EntradaSliderState createState() => _EntradaSliderState();
}

class _EntradaSliderState extends State<EntradaSlider> {
  late double current;

  @override
  void initState() {
    super.initState();
    current = widget.initialValue ??
        (widget.def.context['defaultValue'] as num?)?.toDouble() ??
        0.0;
  }


  @override
  Widget build(BuildContext context) {
    final min = (widget.def.context['min'] as num?)?.toDouble() ?? 0.0;
    final max = (widget.def.context['max'] as num?)?.toDouble() ?? 100.0;
    final step = (widget.def.context['step'] as num?)?.toDouble() ?? 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          min: min,
          max: max,
          divisions: ((max - min) ~/ step).toInt(),
          value: current,
          label: current.toStringAsFixed(0),
          onChanged: (v) {
            setState(() => current = v);
            widget.onChanged(v);
          },
        ),
      ],
    );
  }
}
