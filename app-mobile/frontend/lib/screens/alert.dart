import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chatbot_page.dart'; // Importe a página de chat

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha título e ícone
          children: [
            const Text(
              "Alertas",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            // Ajuste o tamanho do logo para ficar maior, mas sem cortar
            Image.asset(
              'assets/images/logo.png', // Logo à direita
              width: 90,  // Ajuste o tamanho do logo para ser maior
              height: 90, // Aumenta o tamanho do logo para não cortar
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centraliza o conteúdo verticalmente
          children: [
            const SizedBox(height: 20), // Ajuste para centralizar melhor os itens
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

    return InkWell(
      onTap: () {
        // Ação de navegação ou clique
        print('Card clicado: $title');
      },
      child: MouseRegion(
        onEnter: (_) {
          // Alterar o cursor ao passar o mouse
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16), // Menor margem entre os cartões
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Padding menor
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Menor border radius
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 3, // Menos intensidade na sombra
                spreadRadius: 1, // Menos espalhamento da sombra
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 30), // Ícone de alerta menor
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14, // Tamanho do título ajustado
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13, // Tamanho da descrição ajustado
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "📅 $formattedTime",
                          style: const TextStyle(
                            fontSize: 12, // Tamanho da data ajustado
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      // Redireciona para a página de chat (mantém a navegação na pilha)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatBotPage()),
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
                  InkWell(
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
        ),
      ),
    );
  }
}
