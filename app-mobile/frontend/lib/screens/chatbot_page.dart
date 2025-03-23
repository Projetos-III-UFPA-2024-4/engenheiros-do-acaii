import 'package:flutter/material.dart';

class ChatBotPage extends StatefulWidget {
  final String initialMessage; // Parâmetro para a mensagem inicial

  const ChatBotPage({super.key, this.initialMessage = ""});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage.isNotEmpty) {
      _messages.add({"text": widget.initialMessage, "sender": "user"});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat com Açaizinho"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message["text"]!),
                  subtitle: Text(message["sender"] == "user" ? "Você" : "Açaizinho"),
                  tileColor: message["sender"] == "user" ? Colors.blue[50] : Colors.green[50],
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
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "sender": "user"});
      _controller.clear();
    });

    // Aqui você pode chamar o Dialogflow para obter uma resposta
    // Exemplo:
    // String response = await _dialogFlowService.sendMessage(text);
    // setState(() {
    //   _messages.add({"text": response, "sender": "bot"});
    // });
  }
}