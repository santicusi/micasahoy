import 'package:booking_system_flutter/views/pantalla_detalle_paquete.dart';
import 'package:flutter/material.dart';
import '../strapi_service.dart';

class PantallaEnviadoView extends StatefulWidget {
  const PantallaEnviadoView({super.key});

  @override
  State<PantallaEnviadoView> createState() => _PantallaEnviadoViewState();
}

class _PantallaEnviadoViewState extends State<PantallaEnviadoView> {
  final strapiService = StrapiService();
  late Future<List<Map<String, dynamic>>> futurePaquetes;

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

  @override
  void initState() {
    super.initState();
    futurePaquetes = fetchPaquetes();
  }

  Future<List<Map<String, dynamic>>> fetchPaquetes() async {
    return await strapiService.getPaquetesDelUsuario();
  }

  Future<void> _refreshData() async {
    final nuevosDatos = await fetchPaquetes();
    setState(() {
      futurePaquetes = Future.value(nuevosDatos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futurePaquetes,
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
                    'Cargando formularios enviados...',
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
            return RefreshIndicator(
              onRefresh: _refreshData,
              color: primaryGreen,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 80),
                  _buildEmptyState(),
                ],
              ),
            );
          }

          final paquetes = snapshot.data!;
          paquetes.sort((a, b) {
            final fechaA = DateTime.tryParse(a['attributes']?['createdAt'] ?? '') ?? DateTime(2000);
            final fechaB = DateTime.tryParse(b['attributes']?['createdAt'] ?? '') ?? DateTime(2000);
            return fechaB.compareTo(fechaA);
          });

          return Column(
            children: [
              // Header con estadísticas
              Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.cloud_upload,
                        color: primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Formularios Enviados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${paquetes.length} ${paquetes.length == 1 ? 'formulario' : 'formularios'} en total',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildEstadisticasEstado(paquetes),
                  ],
                ),
              ),

              // Lista de paquetes
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: primaryGreen,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: paquetes.length,
                    itemBuilder: (context, index) {
                      final paquete = paquetes[index];
                      final attrs = paquete['attributes'];
                      final estado = attrs?['estado'] ?? 'Pendiente';
                      final fechaCreacion = DateTime.tryParse(attrs?['createdAt'] ?? '')?.toLocal();
                      final fechaFormateada = fechaCreacion != null
                          ? '${fechaCreacion.day.toString().padLeft(2, '0')}/${fechaCreacion.month.toString().padLeft(2, '0')}/${fechaCreacion.year} ${fechaCreacion.hour.toString().padLeft(2, '0')}:${fechaCreacion.minute.toString().padLeft(2, '0')}'
                          : 'Fecha desconocida';

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
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final paqueteId = paquete['id'];
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PantallaDetallePaquete(paqueteId: paqueteId),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  // Icono de estado
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getColorByEstado(estado).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getIconByEstado(estado),
                                      color: _getColorByEstado(estado),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Contenido principal
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Formulario de Levantamiento',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: darkBrown,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule_outlined,
                                              size: 14,
                                              color: textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              fechaFormateada,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        _buildEstadoChip(estado),
                                      ],
                                    ),
                                  ),

                                  // Flecha
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: primaryBrown,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
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
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay formularios enviados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Cuando envíes formularios de levantamiento, aparecerán aquí para que puedas hacer seguimiento de su estado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
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
                  Icons.lightbulb_outline,
                  color: darkGold,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ve a "Inicio" para registrar un predio y realizar tu primer levantamiento',
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
        ],
      ),
    );
  }

  Widget _buildEstadisticasEstado(List<Map<String, dynamic>> paquetes) {
    final estados = <String, int>{};
    for (final paquete in paquetes) {
      final estado = paquete['attributes']?['estado'] ?? 'Pendiente';
      estados[estado] = (estados[estado] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: estados.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getColorByEstado(entry.key),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${entry.value}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getColorByEstado(entry.key),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEstadoChip(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getColorByEstado(estado).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getColorByEstado(estado),
            ),
          ),
        ],
      ),
    );
  }

  String _getEstadoDisplayName(String estado) {
    switch (estado.toLowerCase()) {
      case 'revisado':
        return 'Revisado';
      case 'corregir':
        return 'Por Corregir';
      default:
        return 'Pendiente';
    }
  }

  IconData _getIconByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'revisado':
        return Icons.check_circle_outline;
      case 'corregir':
        return Icons.warning_amber_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _getColorByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'revisado':
        return primaryGreen;
      case 'corregir':
        return accentGold;
      default:
        return primaryBrown;
    }
  }
}

