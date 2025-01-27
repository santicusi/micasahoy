import 'package:flutter/material.dart';

class PantallaEnviadoView extends StatelessWidget {
  const PantallaEnviadoView({super.key});

  // Simulación de datos de predios (pueden venir del backend en el futuro)
  final List<Map<String, dynamic>> predios = const [
    {
      'nombre': 'Predio #1',
      'direccion': 'Dirección del predio',
      'estado': 'En Proceso',
    },
    {
      'nombre': 'Predio #2',
      'direccion': 'Dirección del predio',
      'estado': 'Aprobado',
    },
    {
      'nombre': 'Predio #3',
      'direccion': 'Dirección del predio',
      'estado': 'Rechazado',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Predios registrados:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Lista de predios con su estado
            Expanded(
              child: ListView.builder(
                itemCount: predios.length,
                itemBuilder: (context, index) {
                  final predio = predios[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Columna de información
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  predio['nombre'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  predio['direccion'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Estado del predio con ícono
                          Column(
                            children: [
                              Icon(
                                _getIconByEstado(predio['estado']),
                                size: 30,
                                color: _getColorByEstado(predio['estado']),
                              ),
                              Text(
                                predio['estado'],
                                style: TextStyle(
                                  color: _getColorByEstado(predio['estado']),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Botón Descargar PDF solo para Aprobado/Rechazado
                              if (predio['estado'] != 'En Proceso')
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Descargando PDF de ${predio['nombre']}...'),
                                        backgroundColor:
                                        _getColorByEstado(predio['estado']),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: const Text(
                                    'Descargar PDF',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para obtener el ícono por estado
  IconData _getIconByEstado(String estado) {
    switch (estado) {
      case 'Aprobado':
        return Icons.check_circle_outline;
      case 'Rechazado':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  // Función para obtener el color por estado
  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'Aprobado':
        return Colors.green;
      case 'Rechazado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

