import 'package:flutter/material.dart';
import 'package:frontend/api/dialogflow.dart';

class ChatBotPage extends StatefulWidget {
  final String initialMessage;
  final String alertTitle;

  const ChatBotPage({super.key, this.initialMessage = "", this.alertTitle = ""});

  @override
  _ChatBotPageState createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final DialogFlowService _dialogFlowService = DialogFlowService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage.isNotEmpty) {
      _messages.add({"text": widget.initialMessage, "sender": "user"});
      _sendMessage(widget.initialMessage);
    }
    if (widget.alertTitle.isNotEmpty) {
      _messages.add({"text": "Você está conversando sobre: ${widget.alertTitle}", "sender": "bot"});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/açaizinho.png',
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
        backgroundColor: Colors.purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var message in _messages)
                    _buildMessageBubble(message),
                  const SizedBox(height: 8), // Espaço extra no final
                ],
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> message) {
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
                'assets/images/açaizinho.png',
                width: 30,
                height: 30,
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.purple[100] : Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message["text"] ?? "Mensagem inválida",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Digite uma mensagem...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.purple),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          _sendMessage(_controller.text);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "sender": "user"});
      _controller.clear();
    });

    // Scroll para a nova mensagem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    try {
      String response = await _dialogFlowService.sendMessage(text);
      setState(() {
        _messages.add({"text": response, "sender": "bot"});
      });
      
      // Scroll para a resposta do bot
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      setState(() {
        _messages.add({"text": "Erro na comunicação com o Dialogflow", "sender": "bot"});
      });
    }
  }
}