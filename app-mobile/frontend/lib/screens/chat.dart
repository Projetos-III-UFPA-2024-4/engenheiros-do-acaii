import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final TextEditingController _controller = TextEditingController(); // Para capturar a entrada do usuário
  final DialogFlowService _dialogFlowService = DialogFlowService(); // Instância do serviço do Dialogflow

  @override
  void initState() {
    super.initState();
 //   _testDialogFlow(); // Testa a integração com o DialogFlow ao carregar a página
  }

  // Função de teste para enviar uma mensagem ao Dialogflow e imprimir a resposta
 // void _testDialogFlow() async {
//  String response = await _dialogFlowService.sendMessage("O que fazer em situação de desarme?");
//  print("Resposta do Dialogflow: $response"); // Imprime a resposta no console
// }

  // Método para enviar a pergunta ao Dialogflow e exibir a resposta
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
      backgroundColor: Colors.white, // Cor de fundo branca
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto centralizado com o ícone do Açaizinho à direita
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Açaizinho",
                  style: TextStyle(
                    color: Colors.black, // Texto em preto
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  'assets/images/açaizinho.png', // Ícone maior à direita
                  width: 70,
                  height: 70,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Botões de pergunta com design limpo e interativo
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
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
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
    );
  }

  Widget _buildQuestionCard(String question, IconData icon) {
    return MouseRegion(
      onEnter: (_) {
        // Ação quando o mouse entra na área do card
        setState(() {
          // Adiciona algum efeito de mudança ou cor
        });
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatBotPage(initialMessage: question), // Passa a pergunta como mensagem inicial
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade100, // Cor mais suave para os botões
            borderRadius: BorderRadius.circular(16), // Bordas mais arredondadas
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1), // Sombra mais leve
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.purple, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
