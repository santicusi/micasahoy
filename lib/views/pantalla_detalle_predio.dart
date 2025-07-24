import 'package:booking_system_flutter/views/pantalla_formulario_levantamiento.dart';
import 'package:flutter/material.dart';
import 'package:booking_system_flutter/strapi_service.dart';

import '../data/departamentos_colombia.dart';
import '../data/municipios_colombia.dart';

class PantallaDetallePredio extends StatelessWidget {
  final Map<String, dynamic> predio;
  final int idPredioReal;

  // Paleta de colores GEOCAT
  static const Color primaryGreen = Color(0xFF7CB342);
  static const Color darkGreen = Color(0xFF558B2F);
  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkRed = Color(0xFFC62828);
  static const Color primaryBrown = Color(0xFF8D6E63);
  static const Color darkBrown = Color(0xFF5D4037);
  static const Color accentGold = Color(0xFFFBC02D);
  static const Color darkGold = Color(0xFFF9A825);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF666666);
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  const PantallaDetallePredio({
    super.key,
    required this.predio,
    required this.idPredioReal,
  });

  Widget _buildCampo(String label, dynamic valor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: lightGrey.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: darkBrown,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              '${valor ?? '-'}',
              style: TextStyle(
                color: primaryBrown,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionHeader(String titulo, IconData icono) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryGreen,
            darkGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: pureWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: pureWhite,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: pureWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Información detallada del predio',
                  style: TextStyle(
                    fontSize: 13,
                    color: pureWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearClave(String key) {
    // Formatear claves para mejor legibilidad
    final palabras = key.split('_');
    return palabras
        .map((palabra) => palabra.isNotEmpty
        ? palabra[0].toUpperCase() + palabra.substring(1).toLowerCase()
        : palabra)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Obtener nombres de municipio y departamento si existen
    String? nombreDepartamento;
    String? nombreMunicipio;

    final codigoDepartamento = predio['departamento']?.toString().padLeft(2, '0');
    final codigoMunicipio = predio['municipio']?.toString().padLeft(3, '0');

    if (codigoDepartamento != null && departamentosColombia.containsKey(codigoDepartamento)) {
      nombreDepartamento = departamentosColombia[codigoDepartamento];
    }
    if (codigoMunicipio != null && municipiosColombia.containsKey(codigoMunicipio)) {
      nombreMunicipio = municipiosColombia[codigoMunicipio];
    }

    final keys = predio.keys.toList();

    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        backgroundColor: pureWhite,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: darkBrown,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalle del Predio',
          style: TextStyle(
            color: darkBrown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de la sección
                  _buildSeccionHeader(
                    'Información del Predio',
                    Icons.location_city,
                  ),

                  // Información de ubicación (prioritaria)
                  if (nombreDepartamento != null || nombreMunicipio != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.place,
                                color: primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ubicación',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: darkBrown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (nombreDepartamento != null)
                            _buildInfoRow(
                              'Departamento',
                              nombreDepartamento,
                              Icons.map_outlined,
                            ),
                          if (nombreMunicipio != null)
                            _buildInfoRow(
                              'Municipio',
                              nombreMunicipio,
                              Icons.location_on_outlined,
                            ),
                        ],
                      ),
                    ),
                  ],

                  // Información técnica del predio
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Datos Técnicos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: darkBrown,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        ...keys.map((key) {
                          dynamic valor = predio[key];

                          // Relación: data -> attributes.nombre
                          if (valor is Map && valor.containsKey('data')) {
                            final data = valor['data'];
                            if (data is Map && data.containsKey('attributes')) {
                              valor = data['attributes']['nombre'] ??
                                  data['attributes']['nombre_vista'] ??
                                  data['attributes']['descripcion'] ??
                                  data['id'];
                            } else {
                              valor = data['id'] ?? '-';
                            }
                          }

                          // Fecha ISO
                          if (valor is String && valor.contains('T') && DateTime.tryParse(valor) != null) {
                            final fecha = DateTime.parse(valor);
                            valor = '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
                          }

                          return _buildCampo(_formatearClave(key), valor);
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer con botón de acción
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: pureWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Información sobre el levantamiento
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentGold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: darkGold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Realiza un levantamiento de información para completar los datos del predio',
                            style: TextStyle(
                              fontSize: 13,
                              color: primaryBrown,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón principal
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaFormularioLevantamiento(
                              interesadoId: idPredioReal,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.assignment_outlined),
                      label: const Text(
                        'Realizar Levantamiento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: pureWhite,
                        elevation: 4,
                        shadowColor: primaryGreen.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(
                          darkGreen.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String valor, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icono,
            size: 16,
            color: primaryGreen,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: darkBrown,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: TextStyle(
                color: primaryBrown,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}