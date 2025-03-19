import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat.dart'; // Importe a página de chat

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Alertas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lista de Alertas
            Expanded(
              child: ListView(
                children: [
                  _buildAlertCard(
                    title: "Baixa produção solar",
                    description: "A produção está 20% abaixo do esperado.",
                    timestamp: DateTime.now().subtract(
                      const Duration(minutes: 30),
                    ), // 30 minutos atrás
                    context: context,
                  ),
                  _buildAlertCard(
                    title: "O inversor desarmou!",
                    description:
                        "Verificamos que ocorreu um desarme no inversor.",
                    timestamp: DateTime.now().subtract(
                      const Duration(hours: 2),
                    ), // 2 horas atrás
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir um cartão de alerta
  Widget _buildAlertCard({
    required String title,
    required String description,
    required DateTime timestamp,
    required BuildContext context,
  }) {
    String formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 5),
          Text(
            "📅 $formattedTime",
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Redireciona para a página de chat (mantém a navegação na pilha)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                },
                child: const Text(
                  "Falar com Açaizinho",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Ação de avisar o serviço técnico
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Aviso"),
                        content: const Text("Aviso enviado ao serviço técnico."),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  "Avisar serviço técnico",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
