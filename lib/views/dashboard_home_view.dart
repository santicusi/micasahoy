import 'package:flutter/material.dart';
import 'package:booking_system_flutter/views/pantalla_enviado_view.dart';
import 'package:booking_system_flutter/views/pantalla_perfil_view.dart';
import 'package:booking_system_flutter/strapi_service.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  int _selectedIndex = 0;

  // Lista de widgets correspondientes a cada sección
  final List<Widget> _screens = [
    const HomeSection(),          // Sección de Inicio
    const PantallaEnviadoView(),  // Sección de Enviados
    const PantallaPerfilView(),   // Sección de Perfil
  ];

  // Títulos dinámicos para cada sección
  final List<String> _titles = [
    '¡Bienvenido de nuevo!',
    'Estado del Predio',
    'Perfil del Propietario',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Actualiza la vista actual
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Elimina la flecha de regreso
        title: Text(_titles[_selectedIndex]), // Título dinámico según la pestaña
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, // Muestra la pantalla correspondiente
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud_upload), label: 'Enviados'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Sección de Inicio: Lista de Predios
class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final StrapiService strapiService = StrapiService();
  List<dynamic> predios = []; // Lista para almacenar los datos de Strapi
  bool isLoading = true; // Controlar el estado de carga

  @override
  void initState() {
    super.initState();
    fetchPredios(); // Llamar al método para obtener los datos
  }

  Future<void> fetchPredios() async {
    try {
      // Obtiene los datos de la colección 'COL_AreaTipo'
      final data = await strapiService.getColAreaTipo();
      setState(() {
        predios = data; // Asignar los datos obtenidos a la lista
        isLoading = false; // Cambiar el estado de carga
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Cambiar el estado de carga incluso en caso de error
      });
      print('Error al obtener los predios: $e'); // Imprimir el error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Predios registrados:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          isLoading
              ? const Center(child: CircularProgressIndicator()) // Mostrar indicador de carga
              : Expanded(
            child: ListView.builder(
              itemCount: predios.length,
              itemBuilder: (context, index) {
                // Extraer los atributos de cada predio
                final predio = predios[index]['attributes'];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    title: Text(predio['nombre'] ?? 'Nombre no disponible'),
                    subtitle: Text(predio['descripcion'] ?? 'Sin descripción'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navegar a la pantalla de registros de un predio específico
                      Navigator.pushNamed(context, '/pantalla_registros');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


