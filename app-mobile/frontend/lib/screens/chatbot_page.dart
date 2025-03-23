import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart'; // Importe o pacote dart_openai
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Para carregar a chave da API do .env

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

  @override
  void initState() {
    super.initState();
    // Inicializa o ChatGPT com a chave da API
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

    if (widget.initialMessage.isNotEmpty) {
      _messages.add({"text": widget.initialMessage, "sender": "user"});
      _sendMessage(widget.initialMessage); // Envia a mensagem inicial ao ChatGPT
    }
    if (widget.alertTitle.isNotEmpty) {
      _messages.add({"text": "Você está conversando sobre: ${widget.alertTitle}", "sender": "bot"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat com Açaizinho"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Botão de voltar
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message["sender"] == "user";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message["text"]!,
                      style: const TextStyle(fontSize: 16),
                    ),
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
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Digite uma mensagem...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    _sendMessage(_controller.text);
                  },
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
      // Envia a mensagem ao ChatGPT e obtém a resposta
      final completion = await OpenAI.instance.completion.create(
        model: "text-davinci-003", // Modelo do ChatGPT
        prompt: text,
        maxTokens: 150, // Limite de tokens na resposta
      );
      final response = completion.choices.first.text.trim();

      setState(() {
        _messages.add({"text": response, "sender": "bot"});
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "Erro ao se comunicar com o ChatGPT: $e", "sender": "bot"});
      });
    }
  }
}