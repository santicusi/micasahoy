import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/field_definition.dart';

class EntradaCamara extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final bool enabled;


  const EntradaCamara({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  _EntradaCamaraState createState() => _EntradaCamaraState();
}

class _EntradaCamaraState extends State<EntradaCamara> {
  File? _imagen;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _imagen = File(widget.initialValue!);
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: widget.def.context['maxWidth']?.toDouble(),
      maxHeight: widget.def.context['maxHeight']?.toDouble(),
      imageQuality: widget.def.context['quality'] as int? ?? 80,
    );
    if (foto != null) {
      setState(() => _imagen = File(foto.path));
      widget.onChanged(foto.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.def.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Center(
          child: _imagen == null
              ? IconButton(
            icon: const Icon(Icons.camera_alt, size: 40),
            onPressed: _tomarFoto,
          )
              : GestureDetector(
            onTap: _tomarFoto,
            child: Image.file(
              _imagen!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

