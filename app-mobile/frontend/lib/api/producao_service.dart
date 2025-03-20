import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> getProducaoReal() async {
  // URL da sua API
  final url = Uri.parse('http://localhost:5000/'); // Ajuste a URL conforme a sua configuração

  try {
    // Envia a requisição GET para o backend
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Se a resposta for bem-sucedida (status 200), processa os dados
      final data = jsonDecode(response.body); // Decodifica o JSON recebido
      print('Total de geração no mês: ${data['total_geracao_mes']} kW');
      print('Data mais recente: ${data['data_mais_recente']}');
    } else {
      // Se não for bem-sucedido, exibe uma mensagem de erro
      print('Erro ao obter dados: ${response.statusCode}');
    }
  } catch (e) {
    // Captura e exibe erros de rede
    print('Erro: $e');
  }
}
