import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/field_definition.dart';


class StrapiService {
  final String baseUrl = 'https://minciencias-strapi.onrender.com/api';
  final storage = const FlutterSecureStorage();

  // ———————————————————————————————————————————————————————————————————————————————
  // 1) Helper para construir los headers con el JWT guardado
  // ———————————————————————————————————————————————————————————————————————————————
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ———————————————————————————————————————————————————————————————————————————————
  // 2) Autenticación y gestión de token
  // ———————————————————————————————————————————————————————————————————————————————
  Future<void> saveToken(String token) async {
    await storage.write(key: 'jwt', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt');
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'jwt');
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/local');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': email,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final token = data['jwt'];
        await saveToken(token);
        return {'success': true, 'data': data};
      } else {
        final errorMessage = data['error']?['message'] ?? 'Error desconocido';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    final token = await getToken(); // lee desde flutter_secure_storage

    if (token == null) {
      return {'success': false, 'message': 'Token no encontrado'};
    }

    final response = await http.get(
      Uri.parse('https://minciencias-strapi.onrender.com/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {
        'success': false,
        'message': 'Token inválido o expirado',
      };
    }
  }




  // ———————————————————————————————————————————————————————————————————————————————
  // 3. PERFIL DE USUARIO
// ———————————————————————————————————————————————————————————————————————————————

  /// Obtiene el perfil completo del usuario autenticado, incluyendo relaciones como sexo y tipo_interesado
  Future<Map<String, dynamic>?> getUserProfile() async {
    final headers = await getHeaders();

    final url = Uri.parse('$baseUrl/users/me?populate=sexo,tipo_interesado');
    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      print('🔍 Perfil completo recibido: $data');
      return data;
    }

    print('❌ No se pudo obtener el perfil del usuario');
    return null;
  }

  /// Obtiene los campos permitidos para editar desde el formulario con identificador 'actualizacion-datos-personales'
  /// Obtiene los campos permitidos para editar desde el formulario con identificador 'actualizacion-datos-personales'
  Future<List<String>> getCamposFormularioPerfil() async {
    final headers = await getHeaders();

    final url = Uri.parse(
        '$baseUrl/formularios?filters[identificador][\$eq]=actualizacion-datos-personales&populate=entradas');
    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data['data'].isEmpty) {
        print('⚠️ El formulario con identificador "actualizacion-datos-personales" no existe.');
        return [];
      }

      final List<dynamic> entradas = data['data'][0]['attributes']['entradas'];
      print('📦 Entradas recibidas: $entradas');

      // CAMBIO AQUÍ: usar 'campo' en vez de 'nombre'
      final List<String> campos = entradas
          .where((e) => e['identifier'] != null)
          .map<String>((e) => e['identifier'].toString())
          .toList();
      print('🧩 Campos editables cargados desde formulario: $campos');
      return campos;
    }

    print('❌ No se pudo cargar campos del formulario de perfil');
    return [];
  }

  Future<List<dynamic>?> subirArchivo(String filePath) async {
    final uri = Uri.parse('$baseUrl/upload');
    final token = await getToken();
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('files', filePath));

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final parsed = jsonDecode(resBody);
      print('✅ Archivo subido: $parsed');
      return parsed;
    } else {
      print('❌ Error al subir archivo: $resBody');
      return null;
    }
  }

  /// Actualiza solo los campos permitidos en el perfil del usuario, según el formulario dinámico
  Future<bool> actualizarCamposUsuario(Map<String, dynamic> campos) async {
    final token = await getToken();
    if (token == null) {
      print('⚠️ Token no disponible');
      return false;
    }

    final profile = await getUserProfile();
    if (profile == null || profile['id'] == null) {
      print('⚠️ Perfil no disponible');
      return false;
    }

    final userId = profile['id'];
    final url = Uri.parse('$baseUrl/users/$userId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(campos),
      );

      print('🔁 Enviando actualización: $campos');
      print('🔁 Código de respuesta: ${response.statusCode}');
      print('🔁 Respuesta: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Excepción al actualizar campos del usuario: $e');
      return false;
    }
  }


  Future<List<FieldDefinition>> getDefinicionesCamposPerfil() async {
    final headers = await getHeaders();
    final url = Uri.parse(
        '$baseUrl/formularios?filters[identificador][\$eq]=actualizacion-datos-personales&populate=entradas');

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data['data'].isEmpty) return [];

      final List<dynamic> entradas = data['data'][0]['attributes']['entradas'];

      return entradas.map((e) => FieldDefinition.fromJson(e)).toList();
    }

    return [];
  }



  // ———————————————————————————————————————————————————————————————————————————————
  // 4) Predios del propietario
  // ———————————————————————————————————————————————————————————————————————————————
  Future<List<dynamic>> getPrediosPropietario(String propietarioId) async {
    final headers = await getHeaders();
    final url = Uri.parse(
      '$baseUrl/col-baunitcomointeresados?filters[interesado_cr_interesado][id]=$propietarioId&populate=unidad',
    );


    print('[PREDIOS] URL: $url');
    print('[PREDIOS] Headers: $headers');

    final response = await http.get(url, headers: headers);

    print('[PREDIOS] Código de estado: ${response.statusCode}');
    print('[PREDIOS] Cuerpo de respuesta: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse['data']);
    } else {
      print('[PREDIOS] ERROR: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('No se pudieron cargar los predios desde col-baunitcomointeresado');
    }
  }



  Future<List<dynamic>> getPredioDetalle(String propietarioId) async {
    final headers = await getHeaders();

    final url = Uri.parse(
        '$baseUrl/col-baunitcomointeresado?filters[interesado_cr_interesado][id]=$propietarioId&populate[unidad][populate]=deep'
    );

    final res = await http.get(url, headers: headers);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(decoded['data']);
    } else {
      throw Exception('No se pudo obtener los predios del propietario');
    }
  }






  Future<bool> updatePredio(int id, Map<String, dynamic> datos) async {
    final uri = Uri.parse('$baseUrl/cr-predios/$id');
    final headers = await getHeaders();
    final body = jsonEncode({'data': datos});

    final response = await http.put(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al actualizar predio: ${response.body}');
      return false;
    }
  }

  /// Obtiene la geometría del terreno asociado a un predio específico
  /// Obtiene la geometría del terreno asociado a un interesado (usuario)
  Future<Map<String, dynamic>?> getGeometriaPredio(int interesadoId) async {
    final headers = await getHeaders();

    final url = Uri.parse(
      '$baseUrl/col-baunitcomointeresados?filters[interesado_cr_interesado][id][\$eq]=$interesadoId'
          '&populate[unidad][populate][baunit][populate][ue_cr_terreno]=*',
    );


    print('[GEOMETRIA] URL: $url');

    final response = await http.get(url, headers: headers);

    print('[GEOMETRIA] Código de estado: ${response.statusCode}');
    print('[GEOMETRIA] Respuesta completa: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] as List;

      if (data.isNotEmpty) {
        final unidad = data[0]['attributes']['unidad'];
        final baunit = unidad?['data']?['attributes']?['baunit'];
        final terreno = baunit?['ue_cr_terreno'];

        if (terreno != null && terreno['data'] != null) {
          final geometria = terreno['data']['attributes']['geometria'];
          print('[GEOMETRIA] ✅ Geometría encontrada: $geometria');
          return geometria;
        }
      }

      print('[GEOMETRIA] ⚠️ No se encontró geometría asociada al usuario $interesadoId');
      return null;
    } else {
      print('[GEOMETRIA] ❌ ERROR: ${response.statusCode} - ${response.body}');
      return null;
    }
  }


  /// Obtiene la geometría del predio usando el flujo correcto de 2 consultas
  /// predioId: ID del predio (baunit), no del interesado
  Future<Map<String, dynamic>?> getGeometriaPredioCorregida(int predioId) async {
    final headers = await getHeaders();

    try {
      // 🔹 PASO 1: Consultar col-uebaunits para obtener el ID del terreno
      final url1 = Uri.parse(
          '$baseUrl/col-uebaunits?'
              'populate[0]=ue_cr_terreno&'
              'filters[baunit][\$eq]=$predioId'
      );

      print('[GEOMETRIA_V2] 🔍 Paso 1 - Consultando unidades: $url1');

      final response1 = await http.get(url1, headers: headers);
      print('[GEOMETRIA_V2] Respuesta col-uebaunits: ${response1.statusCode}');
      print('[GEOMETRIA_V2] Body unidades: ${response1.body}');

      if (response1.statusCode != 200) {
        print('[GEOMETRIA_V2] ❌ Error en consulta unidades: ${response1.statusCode}');
        return null;
      }

      final data1 = jsonDecode(response1.body);
      final units = data1['data'] as List;

      if (units.isEmpty) {
        print('[GEOMETRIA_V2] ⚠️ No se encontraron unidades para el predio $predioId');
        return null;
      }

      // Buscar el ID del terreno en las unidades
      int? terrenoId;
      for (var unit in units) {
        final terreno = unit['attributes']['ue_cr_terreno'];
        if (terreno != null && terreno['data'] != null) {
          terrenoId = terreno['data']['id'];
          print('[GEOMETRIA_V2] 🎯 Terreno encontrado en unidad: $terrenoId');
          break;
        }
      }

      if (terrenoId == null) {
        print('[GEOMETRIA_V2] ⚠️ No se encontró terreno asociado al predio $predioId');
        return null;
      }

      // 🔹 PASO 2: Consultar cr-terrenos/{id} para obtener la geometría GeoJSON
      final url2 = Uri.parse('$baseUrl/cr-terrenos/$terrenoId');
      print('[GEOMETRIA_V2] 🔍 Paso 2 - Consultando terreno: $url2');

      final response2 = await http.get(url2, headers: headers);
      print('[GEOMETRIA_V2] Respuesta cr-terrenos: ${response2.statusCode}');
      print('[GEOMETRIA_V2] Body terreno: ${response2.body}');

      if (response2.statusCode != 200) {
        print('[GEOMETRIA_V2] ❌ Error en consulta terreno: ${response2.statusCode}');
        return null;
      }

      final data2 = jsonDecode(response2.body);
      final geometria = data2['data']['attributes']['geometria'];

      if (geometria != null) {
        print('[GEOMETRIA_V2] ✅ Geometría GeoJSON obtenida correctamente');
        print('[GEOMETRIA_V2] Tipo: ${geometria['type']}');
        return geometria as Map<String, dynamic>;
      } else {
        print('[GEOMETRIA_V2] ⚠️ El terreno $terrenoId no tiene geometría definida');
        return null;
      }

    } catch (e) {
      print('[GEOMETRIA_V2] ❌ Excepción: $e');
      return null;
    }
  }





  // ———————————————————————————————————————————————————————————————————————————————
  // ———————————————————————————————————————————————————————————————————————————————
  // 5bis) Obtener definición dinámica del formulario
  // ————————————————————————————————————————————————————————————————————————————
  Future<Map<String, dynamic>?> getFormDefinition(String identificador) async {
    final uri = Uri.parse(
        '$baseUrl/formularios'
            '?filters[identificador][\$eq]=$identificador'
            '&populate=entradas.entrada'
    );
    final headers = await _getAuthHeaders();
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final items = decoded['data'] as List<dynamic>;
      if (items.isEmpty) return null;
      // attributes contiene: punto_final (String) y entradas (List)
      return items.first['attributes'] as Map<String, dynamic>;
    } else {
      throw Exception('Error al obtener definición de formulario: ${resp.body}');
    }
  }

  Future<Map<String, dynamic>?> getFormularioLevantamiento() async {
    final uri = Uri.parse('$baseUrl/formularios/levantamiento-informacion?populate=entradas.entrada');
    final headers = await _getAuthHeaders();
    final resp = await http.get(uri, headers: headers);
    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      return decoded['data']?['attributes'];
    } else {
      throw Exception('Error al obtener el formulario de levantamiento: ${resp.body}');
    }
  }

  Future<Map<String, String>> getHeaders() async {
    return await _getAuthHeaders();
  }

  // ———————————————————————————————————————————————————————————————————————————————
  // 6bis) Enviar datos dinámicos de cualquier formulario
  Future<bool> submitForm(String endpoint, Map<String, dynamic> formData) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getAuthHeaders();
    // Strapi espera { data: { campo1: valor1, campo2: valor2, … } }
    final body = jsonEncode({'data': formData});
    final resp = await http.post(uri, headers: headers, body: body);
    return resp.statusCode == 200 || resp.statusCode == 201;
  }


  Future<bool> post(Uri uri, {required Map<String, String> headers, required Map<String, dynamic> body}) async {
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print('📤 [DEBUG] POST ${uri.path} -> ${response.statusCode}');
    print('📥 [DEBUG] Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception(response.body);
    }
  }



  Future<List<Map<String, dynamic>>> getPaquetesDelUsuario() async {
    final profile = await getUserProfile();
    final userId = profile?['id'];
    if (userId == null) return [];

    final uri = Uri.parse(
        '$baseUrl/paquetes?filters[cr_interesado][id][\$eq]=$userId'
    );
    final headers = await getHeaders();
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return List<Map<String, dynamic>>.from(json['data']);
    } else {
      print('❌ Error al obtener paquetes: ${resp.body}');
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> getSolicitudesPorPaquete(int paqueteId) async {
    final headers = await getHeaders();
    final uri = Uri.parse('$baseUrl/solicitudes?filters[paquete][id]=$paqueteId');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(decoded['data']);
    } else {
      print('❌ Error al obtener solicitudes del paquete: ${response.body}');
      return [];
    }
  }


  Future<Map<String, dynamic>> registerUserExtendido({
    required String email,
    required String password,
    required String primerNombre,
    required String segundoNombre,
    required String primerApellido,
    required String segundoApellido,
    required String username,
    required String numeroDocumento,
    required int tipoDocumentoId,
    required int sexoId,
    required int etnicoId,
    required int tipoInteresadoId,
    required bool esCampesino,
    required String espacioDeNombres,
    required String localId,
    required String comienzoVidaUtilVersion,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/local/register');

    final headers = {'Content-Type': 'application/json'};

    final body = {
      'email': email,
      'password': password,
      'username': username,
      'primer_nombre': primerNombre,
      'segundo_nombre': segundoNombre,
      'primer_apellido': primerApellido,
      'segundo_apellido': segundoApellido,
      'numero_documento': numeroDocumento,
      'tipo_documento': tipoDocumentoId,
      'sexo': sexoId,
      'autoreconocimientoetnico': etnicoId,
      'autoreconocimientocampesino': esCampesino,
      'tipo_interesado': tipoInteresadoId,
      'espacio_de_nombres': espacioDeNombres,
      'local_id': localId,
      'comienzo_vida_util_version': comienzoVidaUtilVersion,
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        print('❌ Error detallado Strapi: ${response.body}');
        final message = data['error']?['message'] ?? 'Error desconocido';
        return {'success': false, 'message': message};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }


  Future<List<String>> getCamposFormularioRegistro() async {
    final url = Uri.parse('$baseUrl/formularios?filters[identificador][\$eq]=formulario-registro-usuarios&populate=entradas');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final entradas = data['data'][0]['attributes']['entradas'] as List;
        return entradas.map<String>((e) => e['nombre'] as String).toList();
      } else {
        throw Exception('Error al obtener campos del formulario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }








  // ———————————————————————————————————————————————————————————————————————————————
  // 7) Otros catálogos (ejemplo: col-areatipos)
  // ———————————————————————————————————————————————————————————————————————————————
  Future<List<dynamic>> getColAreaTipo() async {
    final url = Uri.parse('$baseUrl/col-areatipos');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Error al obtener col-areatipos: ${response.statusCode}');
    }
  }

  // ———————————————————————————————————————————————————————————————————————————————
// 8) Crear un nuevo predio (col-baunitcomointeresado)
// ———————————————————————————————————————————————————————————————————————————————
  Future<int?> crearPredio(Map<String, dynamic> datos) async {
    final uri = Uri.parse('$baseUrl/col-baunitcomointeresado');
    final headers = await _getAuthHeaders();
    final body = jsonEncode({'data': datos});

    print('[CREAR PREDIO] Enviando POST a: $uri');
    print('[CREAR PREDIO] Headers: $headers');
    print('[CREAR PREDIO] Body: $body');

    try {
      final response = await http.post(uri, headers: headers, body: body);

      print('[CREAR PREDIO] Código de estado: ${response.statusCode}');
      print('[CREAR PREDIO] Respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        final predioId = json['data']['id'];
        print('[CREAR PREDIO] Predio creado con ID: $predioId');
        return predioId;
      } else {
        print('[CREAR PREDIO] Error al crear predio: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[CREAR PREDIO] Excepción: $e');
      return null;
    }
  }

}