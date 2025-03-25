// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

class DialogFlowService {
  final String _projectId = 'chatbot-smartvolt-sij9'; // Substitua pelo ID do seu projeto
  final String _sessionId = Uuid().v4(); // Pode ser dinâmico
  final String _languageCode = 'pt-BR';
  final String _credentialsPath = 'assets/credentials/chatbot-smartvolt-sij9-cca54af4ec1f.json';

  Future<String> sendMessage(String message) async {
    try {
      // Carrega as credenciais da conta de serviço
      final serviceAccountCredentials = await _getCredentials();

      // Autentica com o Google Cloud
      final authClient = await clientViaServiceAccount(
        serviceAccountCredentials,
        ['https://www.googleapis.com/auth/cloud-platform'],
      );

      // URL da API do Dialogflow
      final dialogflowUrl =
          'https://dialogflow.googleapis.com/v2/projects/$_projectId/agent/sessions/$_sessionId:detectIntent';

      // Corpo da requisição
      final requestPayload = jsonEncode({
        'queryInput': {
          'text': {
            'text': message,
            'languageCode': _languageCode,
          },
        },
      });

      // Faz a requisição HTTP
      final response = await authClient.post(
        Uri.parse(dialogflowUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestPayload,
      );

      // Processa a resposta
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['queryResult']['fulfillmentText'] ?? 'Desculpe, não entendi.';
      } else {
        print("Erro: ${response.statusCode}, ${response.body}");
        throw Exception('Erro na comunicação com o Dialogflow: ${response.statusCode}');
      }
    } catch (e) {
      print("Exceção: $e");
      return 'Erro na comunicação com o Dialogflow';
    }
  }

  // Método para carregar as credenciais do arquivo JSON
  Future<ServiceAccountCredentials> _getCredentials() async {
    try {
      final jsonString = await rootBundle.loadString(_credentialsPath);
      final jsonMap = jsonDecode(jsonString);
      return ServiceAccountCredentials.fromJson(jsonMap);
    } catch (e) {
      print("Erro ao carregar credenciais: $e");
      throw Exception("Erro ao carregar credenciais: $e");
    }
  }
}