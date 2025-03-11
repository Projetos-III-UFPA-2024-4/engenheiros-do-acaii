import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _answer = ""; // Variável para armazenar a resposta

  // Método para definir a resposta com base no botão clicado
  void _showAnswer(String question) {
    setState(() {
      if (question == "O que fazer em situação de desarme?") {
        _answer =
            "Se o seu inversor desarmou, verifique se há oscilações na rede elétrica. Caso o problema persista, entre em contato com o suporte técnico.";
      } else if (question == "Quanto é a minha fatura atual?") {
        _answer =
            "A sua fatura atual é baseada no consumo dos últimos 30 dias. Acesse o app SmartVolt para ver valores detalhados.";
      } else if (question == "Por que estou produzindo menos?") {
        _answer =
            "A produção pode estar abaixo do esperado devido a fatores como sujeira nos painéis solares, sombreamento ou falhas no inversor.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone e descrição do assistente
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

            // Botões interativos
            _buildQuestionButton("O que fazer em situação de desarme?"),
            _buildQuestionButton("Quanto é a minha fatura atual?"),
            _buildQuestionButton("Por que estou produzindo menos?"),

            const SizedBox(height: 20),

            // Área de Resposta
            if (_answer.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  _answer,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Método para criar botões estilizados
  Widget _buildQuestionButton(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showAnswer(question),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          question,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
