import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://3.228.24.214:8080/servicos/crud-dados"; // Ajuste conforme necessário

  static Future<List<dynamic>> buscarPessoas() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/medicao_consumo"));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Converte JSON para lista
      } else {
        throw Exception("Erro ao carregar dados");
      }
    } catch (e) {
      throw Exception("Erro de conexão: $e");
    }
  }
}
