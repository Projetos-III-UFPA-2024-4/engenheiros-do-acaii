import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTService {
  ChatGPTService() {
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!; // Carrega a chave do .env
  }

  Future<String> sendMessage(String message) async {
    try {
      final completion = await OpenAI.instance.completion.create(
        model: "text-davinci-003", // Modelo do ChatGPT
        prompt: message,
        maxTokens: 150, // Limite de tokens na resposta
      );
      return completion.choices.first.text.trim();
    } catch (e) {
      return "Erro ao se comunicar com o ChatGPT: $e";
    }
  }
}