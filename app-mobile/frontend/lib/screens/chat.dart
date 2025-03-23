// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:frontend/screens/chatbot_page.dart';
import 'package:intl/intl.dart';
import 'package:frontend/api/dialogflow.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _answer = ""; // Armazena a resposta do chatbot
  String _timestamp = ""; // Armazena data e hora da resposta
  // ignore: unused_field
  final TextEditingController _controller = TextEditingController(); // Para capturar a entrada do usuário
  // ignore: unused_field
  final List<Map<String, String>> _messages = []; // Armazena o histórico de mensagens
  final DialogFlowService _dialogFlowService = DialogFlowService(); // Instância do serviço do Dialogflow

  @override
  void initState() {
    super.initState();
    _testDialogFlow(); // Testa a integração com o DialogFlow ao carregar a página
  }

  // Função de teste para enviar uma mensagem ao Dialogflow e imprimir a resposta
    void _testDialogFlow() async {
    String response = await _dialogFlowService.sendMessage("O que fazer em situação de desarme?");
    print("Resposta do Dialogflow: $response");// Imprime a resposta no console

    // Se você quiser mostrar a resposta na tela, também pode fazer isso:
    //setState(() {
    //  _answer = response; // Exibe a resposta na interface
   // });
  }

  // Método para enviar a pergunta ao Dialogflow e exibir a resposta
  // ignore: unused_element
  void _showAnswer(String question) async {
    setState(() {
      _timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    });

    try {
      // Envia a pergunta ao Dialogflow
      String response = await _dialogFlowService.sendMessage(question);

      // Atualiza a resposta na interface
      setState(() {
        _answer = response;
      });
    } catch (e) {
      // Em caso de erro, exibe uma mensagem de erro
      setState(() {
        _answer = "Erro na comunicação com o Dialogflow: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho do assistente
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Açaizinho",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Assistente do SmartVolt",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Botões interativos em forma de cartões
              _buildQuestionCard(
                "O que fazer em situação de desarme?",
                Icons.warning_amber_rounded,
              ),
              _buildQuestionCard(
                "Quanto é a minha fatura atual?",
                Icons.receipt_long,
              ),
              _buildQuestionCard(
                "Por que estou produzindo menos?",
                Icons.lightbulb_outline,
              ),
              _buildQuestionCard(
                "Como otimizar meu consumo de energia?",
                Icons.energy_savings_leaf,
              ),
              _buildQuestionCard(
                "Quais os benefícios da energia solar?",
                Icons.wb_sunny,
              ),

              const SizedBox(height: 20),

              // Exibição da resposta e do horário do alerta
              if (_answer.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🕒 $_timestamp",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _answer,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildQuestionCard(String question, IconData icon) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatBotPage(initialMessage: question,), // Passa a pergunta como mensagem inicial
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black45,
            size: 18,
          ),
        ],
      ),
    ),
  );
}
}
