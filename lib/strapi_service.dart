import 'dart:convert';
import 'package:http/http.dart' as http;

class StrapiService {
  final String baseUrl = 'https://minciencias-strapi.onrender.com/api';

  // Método para obtener los datos de la colección 'COL_AreaTipo'
  Future<List<dynamic>> getColAreaTipo() async {
    final url = Uri.parse('$baseUrl/col-areatipos'); // Endpoint de la API
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // Retorna los datos de la colección
    } else {
      throw Exception('Error al obtener los datos: ${response.statusCode}');
    }
  }
}
