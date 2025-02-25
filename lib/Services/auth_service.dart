import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/LoginResponse.dart';
import '../Utilerias/Ambiente.dart';

class AuthService {
  final http.Client client;

  AuthService({required this.client}); // Inyectamos el cliente

  Future<LoginResponse> login(String email, String password) async {
    final response = await client.post( // Usamos el cliente inyectado
      Uri.parse('${Ambiente.urlServe}/api/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error de conexión');
    }
  }
}

