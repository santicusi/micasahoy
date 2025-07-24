import 'package:flutter/material.dart';
import '../strapi_service.dart';

class PantallaDetallePaquete extends StatelessWidget {
  final int paqueteId;

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

  const PantallaDetallePaquete({super.key, required this.paqueteId});

  @override
  Widget build(BuildContext context) {
    final strapiService = StrapiService();

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
          'Respuestas del Formulario',
          style: TextStyle(
            color: darkBrown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: strapiService.getSolicitudesPorPaquete(paqueteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryGreen,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando respuestas...',
                    style: TextStyle(
                      color: primaryBrown,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final respuestas = snapshot.data!;

          // Agrupar respuestas por estado para mostrar estadísticas
          final estadisticas = _calcularEstadisticas(respuestas);

          return Column(
            children: [
              // Header con estadísticas
              _buildHeaderEstadisticas(estadisticas, respuestas.length),

              // Lista de respuestas
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: respuestas.length,
                  itemBuilder: (context, index) {
                    final respuesta = respuestas[index]['attributes'];
                    final pregunta = respuesta['title'] ?? 'Pregunta sin título';
                    final valor = respuesta['valor'] ?? '';
                    final estado = respuesta['estado'] ?? 'Pendiente';
                    final retro = respuesta['retroalimentacion'] ?? '';

                    return _buildRespuestaCard(
                      pregunta: pregunta,
                      valor: valor,
                      estado: estado,
                      retroalimentacion: retro,
                      index: index + 1,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: pureWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryBrown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: primaryBrown,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No hay respuestas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Este formulario aún no tiene respuestas registradas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderEstadisticas(Map<String, int> estadisticas, int total) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assignment_turned_in,
                  color: primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen del Formulario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$total respuestas registradas',
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (estadisticas.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: estadisticas.entries.map((entry) {
                final porcentaje = ((entry.value / total) * 100).round();
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _getColorByEstado(entry.key).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getColorByEstado(entry.key).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${entry.value}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _getColorByEstado(entry.key),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getEstadoDisplayName(entry.key),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getColorByEstado(entry.key),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '$porcentaje%',
                          style: TextStyle(
                            fontSize: 10,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRespuestaCard({
    required String pregunta,
    required String valor,
    required String estado,
    required String retroalimentacion,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la pregunta
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pregunta,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildEstadoChip(estado),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Respuesta
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: lightGrey.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: primaryBrown,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Respuesta:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryBrown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatearRespuesta(valor),
                    style: TextStyle(
                      fontSize: 14,
                      color: darkBrown,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Retroalimentación (si existe)
            if (retroalimentacion.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentGold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentGold.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          size: 16,
                          color: darkGold,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Retroalimentación:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: darkGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      retroalimentacion,
                      style: TextStyle(
                        fontSize: 14,
                        color: primaryBrown,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoChip(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorByEstado(estado).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getColorByEstado(estado).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getColorByEstado(estado),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getEstadoDisplayName(estado),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getColorByEstado(estado),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearRespuesta(String valor) {
    if (valor.isEmpty) return 'Sin respuesta';

    // Si es un JSON o texto muy largo, formatearlo mejor
    if (valor.length > 100) {
      return valor.substring(0, 97) + '...';
    }

    return valor;
  }

  Map<String, int> _calcularEstadisticas(List<Map<String, dynamic>> respuestas) {
    final estadisticas = <String, int>{};
    for (final respuesta in respuestas) {
      final estado = respuesta['attributes']['estado'] ?? 'Pendiente';
      estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
    }
    return estadisticas;
  }

  String _getEstadoDisplayName(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'revisado con errores':
        return 'Revisado con errores';
      case 'correcto':
        return 'Correcto';
      case 'se requiere más información':
        return 'Se requiere más información';
      default:
        return estado; // por si acaso viene algo nuevo
    }
  }


  Color _getColorByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return primaryBrown;
      case 'revisado con errores':
        return accentGold;
      case 'correcto':
        return primaryGreen;
      case 'se requiere más información':
        return primaryRed;
      default:
        return Colors.grey;
    }
  }

}