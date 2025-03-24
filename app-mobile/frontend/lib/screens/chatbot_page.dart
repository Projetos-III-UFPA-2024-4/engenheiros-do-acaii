import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/api/dialogflow.dart'; // Importe o DialogFlowService

class ChatBotPage extends StatefulWidget {
  final String initialMessage; // Parâmetro para a mensagem inicial
  final String alertTitle; // Título do alerta

  const ChatBotPage({super.key, this.initialMessage = "", this.alertTitle = ""});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final DialogFlowService _dialogFlowService = DialogFlowService(); // Instância do serviço

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage.isNotEmpty) {
      _messages.add({"text": widget.initialMessage, "sender": "user"});
      _sendMessage(widget.initialMessage); // Envia a mensagem inicial ao Dialogflow
    }
    if (widget.alertTitle.isNotEmpty) {
      _messages.add({"text": "Você está conversando sobre: ${widget.alertTitle}", "sender": "bot"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/açaizinho.png', // Ícone do Açaizinho
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              "Açaízinho",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.purple, // Cor temática
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Botão de voltar
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "user";

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            'assets/images/açaizinho.png', // Ícone do Açaizinho
                            width: 40,
                            height: 40,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.purple[100] : Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(),
                              blurRadius: 5,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          message["text"] ?? "Mensagem inválida",
                          style: TextStyle(
                            color: isUser ? Colors.black87 : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Digite uma mensagem...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "sender": "user"});
      _controller.clear();
    });

    try {
      // Envia a mensagem ao Dialogflow e obtém a resposta
      String response = await _dialogFlowService.sendMessage(text);
      setState(() {
        _messages.add({"text": response, "sender": "bot"});
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "Erro na comunicação com o Dialogflow: $e", "sender": "bot"});
      });
    }
  }
}