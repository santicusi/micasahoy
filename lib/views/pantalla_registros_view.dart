import 'package:flutter/material.dart';

class PantallaRegistrosView extends StatelessWidget {
  const PantallaRegistrosView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    final nombrePredio = arguments?['nombrePredio'] ?? 'Predio';

    return DefaultTabController(
      length: 4, // Número total de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text('Registros de $nombrePredio'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Física'),
              Tab(text: 'Jurídica'),
              Tab(text: 'Económica'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            InformacionGeneralTab(),   // Widget Información General
            InformacionFisicaTab(),    // Widget Información Física
            InformacionJuridicaTab(),  // Widget Información Jurídica
            InformacionEconomicaTab(), // Widget Información Económica
          ],
        ),
      ),
    );
  }
}

// Widget para Información General
class InformacionGeneralTab extends StatefulWidget {
  const InformacionGeneralTab({super.key});

  @override
  State<InformacionGeneralTab> createState() => _InformacionGeneralTabState();
}

class _InformacionGeneralTabState extends State<InformacionGeneralTab> {
  bool isEditing = false;

  final TextEditingController areaController =
  TextEditingController(text: '120 m²');
  final TextEditingController direccionController =
  TextEditingController(text: 'Calle 123 #45-67');
  final TextEditingController departamentoController =
  TextEditingController(text: 'Valle del Cauca');
  final TextEditingController municipioController =
  TextEditingController(text: 'Santiago de Cali');
  String tipoPredio = 'Residencial';

  final List<String> opcionesTipoPredio = [
    'Residencial',
    'Comercial',
    'Industrial',
    'Rural'
  ];

  @override
  Widget build(BuildContext context) {
    return _buildTabContent(
      'Información General del Predio',
      [
        _buildTextField('Área del Predio', areaController),
        _buildTextField('Dirección', direccionController),
        _buildTextField('Departamento', departamentoController),
        _buildTextField('Municipio', municipioController),
        _buildDropdown('Tipo de Predio', opcionesTipoPredio),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: tipoPredio,
      onChanged: isEditing
          ? (value) {
        setState(() {
          tipoPredio = value!;
        });
      }
          : null,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent(String title, List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...children.map((widget) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: widget,
          )),
          Center(
            child: isEditing
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cambios guardados correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Cambios'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white),
              child: const Text('Editar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para Información Económica
class InformacionEconomicaTab extends StatefulWidget {
  const InformacionEconomicaTab({super.key});

  @override
  State<InformacionEconomicaTab> createState() =>
      _InformacionEconomicaTabState();
}

class _InformacionEconomicaTabState extends State<InformacionEconomicaTab> {
  bool isEditing = false;

  // Controladores con valores predeterminados
  final TextEditingController valorPredioController =
  TextEditingController(text: '\$150,000');
  final TextEditingController impuestosController =
  TextEditingController(text: '\$1,500');
  final TextEditingController mantenimientoController =
  TextEditingController(text: '\$2,000');
  String usoPredio = 'Residencial';

  // Opciones de uso del predio
  final List<String> opcionesUsoPredio = ['Residencial', 'Comercial', 'Mixto'];

  @override
  Widget build(BuildContext context) {
    return _buildTabContent(
      'Información Económica del Predio',
      [
        _buildTextField('Valor del Predio', valorPredioController),
        _buildTextField('Impuestos Anuales', impuestosController),
        _buildTextField(
            'Costo de Mantenimiento Anual', mantenimientoController),
        _buildDropdown('Uso del Predio', opcionesUsoPredio),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: usoPredio,
      onChanged: isEditing
          ? (value) {
        setState(() {
          usoPredio = value!;
        });
      }
          : null,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent(String title, List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children.map((widget) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: widget,
          )),
          Center(
            child: isEditing
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cambios guardados correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Cambios'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Restaurar los valores iniciales
                      valorPredioController.text = '\$150,000';
                      impuestosController.text = '\$1,500';
                      mantenimientoController.text = '\$2,000';
                      usoPredio = 'Residencial';
                      isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Editar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para Información Física (reutilizado)
class InformacionFisicaTab extends StatefulWidget {
  const InformacionFisicaTab({super.key});

  @override
  State<InformacionFisicaTab> createState() => _InformacionFisicaTabState();
}

class _InformacionFisicaTabState extends State<InformacionFisicaTab> {
  bool isEditing = false;

  // Valores iniciales para los campos
  String tipoArmazon = 'Madera';
  String materialMuros = 'Ladrillo';
  String materialTecho = 'Metal';
  String estadoConservacion = 'Bueno';

  // Opciones de los Dropdowns
  final List<String> opcionesMaterial = ['Madera', 'Hormigón', 'Metal', 'Ladrillo'];
  final List<String> opcionesEstado = ['Bueno', 'Regular', 'Malo'];

  @override
  Widget build(BuildContext context) {
    return _buildTabContent(
      'Información Física del Predio',
      [
        _buildDropdown('Tipo de Armazón', opcionesMaterial, tipoArmazon, (value) {
          setState(() {
            tipoArmazon = value!;
          });
        }),
        _buildDropdown('Material de Muros', opcionesMaterial, materialMuros, (value) {
          setState(() {
            materialMuros = value!;
          });
        }),
        _buildDropdown('Material de Techo', opcionesMaterial, materialTecho, (value) {
          setState(() {
            materialTecho = value!;
          });
        }),
        _buildDropdown('Estado de Conservación', opcionesEstado, estadoConservacion, (value) {
          setState(() {
            estadoConservacion = value!;
          });
        }),
      ],
    );
  }

  // Widget reutilizable para el Dropdown
  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      onChanged: isEditing ? onChanged : null,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  // Contenido reutilizable con título y botones de acción
  Widget _buildTabContent(String title, List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children.map((widget) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: widget,
          )),
          Center(
            child: isEditing
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cambios guardados correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Cambios'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Restaurar valores iniciales
                      tipoArmazon = 'Madera';
                      materialMuros = 'Ladrillo';
                      materialTecho = 'Metal';
                      estadoConservacion = 'Bueno';
                      isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Editar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para Información Jurídica (reutilizado)
class InformacionJuridicaTab extends StatefulWidget {
  const InformacionJuridicaTab({super.key});

  @override
  State<InformacionJuridicaTab> createState() => _InformacionJuridicaTabState();
}

class _InformacionJuridicaTabState extends State<InformacionJuridicaTab> {
  bool isEditing = false;

  // Controladores con valores iniciales
  final TextEditingController propietarioController =
  TextEditingController(text: 'Juan Pérez');
  final TextEditingController fechaAdquisicionController =
  TextEditingController(text: '01/01/2020');
  final TextEditingController fechaRestriccionController =
  TextEditingController(text: '15/06/2021');
  String tipoRestriccion = 'Embargo';

  // Opciones de tipo de restricción
  final List<String> opcionesRestriccion = ['Embargo', 'Gravamen', 'Otro'];

  @override
  Widget build(BuildContext context) {
    return _buildTabContent(
      'Información Jurídica del Predio',
      [
        _buildTextField('Nombre del Propietario Actual', propietarioController),
        _buildTextField('Fecha de Adquisición', fechaAdquisicionController),
        _buildDropdown('Tipo de Restricción', opcionesRestriccion, tipoRestriccion,
                (value) {
              setState(() {
                tipoRestriccion = value!;
              });
            }),
        _buildTextField(
            'Fecha de Inicio de la Restricción', fechaRestriccionController),
      ],
    );
  }

  // Widget reutilizable para campos de texto
  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // Widget reutilizable para Dropdowns
  Widget _buildDropdown(String label, List<String> items, String value,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      onChanged: isEditing ? onChanged : null,
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  // Contenido reutilizable con título y botones de acción
  Widget _buildTabContent(String title, List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children.map((widget) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: widget,
          )),
          Center(
            child: isEditing
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isEditing = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cambios guardados correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Cambios'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Restaurar valores iniciales
                      propietarioController.text = 'Juan Pérez';
                      fechaAdquisicionController.text = '01/01/2020';
                      fechaRestriccionController.text = '15/06/2021';
                      tipoRestriccion = 'Embargo';
                      isEditing = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            )
                : ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Editar'),
            ),
          ),
        ],
      ),
    );
  }
}

// Funciones reutilizables para widgets
Widget _buildTextField(String label) {
  return TextField(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget _buildDropdown(String label, List<String> items) {
  return DropdownButtonFormField<String>(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    items: items.map((item) {
      return DropdownMenuItem<String>(
        value: item,
        child: Text(item),
      );
    }).toList(),
    onChanged: (value) {},
  );
}

Widget _buildEnviarButton(BuildContext context, String section) {
  return Center(
    child: ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$section enviada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      child: const Text('Enviar'),
    ),
  );
}

Widget _buildTabContent(BuildContext context, String title, List<Widget> children) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...children.map((widget) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: widget,
        )),
        _buildEnviarButton(context, title),
      ],
    ),
  );
}


