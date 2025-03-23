import 'dart:convert';
import 'package:http/http.dart' as http;

class ConsumoService {
  static const baseUrl = 'http://localhost:5000/servicos/crud-dados';

  // Chama o endpoint de produção, passando o parâmetro de período
  static Future<Map<String, dynamic>> getConsumoReal(String periodo) async {
    final url = Uri.parse('$baseUrl/consumo-real?periodo=$periodo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar dados de produção');
    }
  }

  // Chama o endpoint de previsão
  static Future<Map<String, dynamic>> getPrevisaoConsumo(String periodo) async {
    final url = Uri.parse('$baseUrl/previsao-consumo?periodo=$periodo');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao carregar dados de previsão');
    }
  }
}
