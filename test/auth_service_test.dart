import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediapp/Services/auth_service.dart';
import 'package:mediapp/Models/LoginResponse.dart';

// 🔹 Esto genera el mock automáticamente
@GenerateMocks([http.Client])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Login', () {
    late AuthService authService;
    late MockClient client;

    setUp(() {
      client = MockClient();
      authService = AuthService(client: client);
    });

    test('Login exitoso devuelve LoginResponse con acceso "ok"', () async {
      final mockResponse = {
        "acceso": "ok",
        "idUsuario": 123
      };

      when(client.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await authService.login('test@example.com', 'password');

      expect(result.acceso, 'ok');
      expect(result.idUsuario, 123);
    });

    test('Login con error lanza una excepción', () async {
      when(client.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      expect(
            () async => await authService.login('test@example.com', 'password'),
        throwsException,
      );
    });
  });
}
