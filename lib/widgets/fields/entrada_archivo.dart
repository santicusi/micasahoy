import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/field_definition.dart';

class EntradaArchivo extends StatefulWidget {
  final FieldDefinition def;
  final ValueChanged<String> onChanged;
  final String? initialValue;
  final bool enabled;


  const EntradaArchivo({
    Key? key,
    required this.def,
    required this.onChanged,
    this.initialValue,
    required this.enabled,
  }) : super(key: key);

  @override
  _EntradaArchivoState createState() => _EntradaArchivoState();
}

class _EntradaArchivoState extends State<EntradaArchivo>
    with AutomaticKeepAliveClientMixin {
  String? fileName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if ((widget.initialValue ?? '').toString().isNotEmpty) {
      fileName = Uri.file(widget.initialValue!).pathSegments.last;
      print('📎 initState - Archivo inicial: $fileName');
    }
  }

  @override
  void didUpdateWidget(covariant EntradaArchivo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newPath = widget.initialValue;
    final currentFile = fileName ?? '';
    if (newPath != null && !currentFile.contains(Uri.file(newPath).pathSegments.last)) {
      setState(() {
        fileName = Uri.file(newPath).pathSegments.last;
        print('🔁 didUpdateWidget - Se actualizó archivo: $fileName');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAlive

    final allowed = List<String>.from(widget.def.context['accept'] ?? []);
    final maxMb = widget.def.context['maxFileSize'] as int? ?? 50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.attach_file),
          label: const Text('Seleccionar archivo'),
          onPressed: () async {
            final allowed = List<String>.from(widget.def.context['accept'] ?? [])
                .map((e) => e.trim().replaceAll('.', '').toLowerCase())
                .where((e) => e.isNotEmpty)
                .toList();

            print('🛠 Extensiones permitidas: $allowed');

            final res = await FilePicker.platform.pickFiles(
              type: allowed.isEmpty ? FileType.any : FileType.custom,
              allowedExtensions: allowed,
            );

            if (res != null && res.files.single.size <= maxMb * 1024 * 1024) {
              setState(() {
                fileName = res.files.single.name;
              });
              widget.onChanged(res.files.single.path!);
              print('📂 Archivo seleccionado: ${res.files.single.path}');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Archivo no válido o muy pesado')),
              );
            }
          },
        ),
        if (fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('📎 Archivo: $fileName'),
          ),
      ],
    );
  }
}


