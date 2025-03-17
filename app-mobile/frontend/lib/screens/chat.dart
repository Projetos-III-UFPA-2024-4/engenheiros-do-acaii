import 'package:flutter/material.dart';
import 'package:frontend/screens/alert.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _answer = ""; // Armazena a resposta
  String _timestamp = ""; // Armazena data e hora da resposta

  // Método para definir a resposta com base no botão clicado
  void _showAnswer(String question) {
    setState(() {
      _timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

      if (question == "O que fazer em situação de desarme?") {
        _answer =
            "🔌 **Se o seu inversor desarmou:**\n\n"
            "1️⃣ Verifique se há oscilações na rede elétrica.\n"
            "2️⃣ Cheque se há mensagens de erro no display do inversor.\n"
            "3️⃣ Reinicie o sistema desligando e religando o disjuntor.\n"
            "4️⃣ Caso o problema persista, entre em contato com o suporte técnico.\n\n"
            "📞 **Assistência Técnica:** 0800-123-4567 (Disponível 24h)";
      } else if (question == "Quanto é a minha fatura atual?") {
        _answer =
            "💰 **Sua fatura atual** é baseada no consumo dos últimos 30 dias.\n\n"
            "📊 Acesse o **app SmartVolt** para ver os detalhes, incluindo:\n"
            "✔️ Histórico de consumo\n"
            "✔️ Comparação com meses anteriores\n"
            "✔️ Dicas para economia\n\n"
            "📞 **Atendimento ao Cliente:** 0800-987-6543";
      } else if (question == "Por que estou produzindo menos?") {
        _answer =
            "☀️ **Possíveis causas para baixa produção solar:**\n\n"
            "🔍 **1. Painéis sujos** – Limpe os painéis regularmente.\n"
            "🌳 **2. Sombreamento** – Verifique se há árvores ou prédios bloqueando a luz solar.\n"
            "⚡ **3. Falha no inversor** – Verifique se o inversor está funcionando corretamente.\n\n"
            "📞 **Suporte Técnico:** 0800-111-2222 (Horário Comercial)";
      } else if (question == "Como otimizar meu consumo de energia?") {
        _answer =
            "🔋 **Dicas para otimizar seu consumo:**\n\n"
            "💡 Substitua lâmpadas incandescentes por LED.\n"
            "🔌 Evite deixar aparelhos em stand-by.\n"
            "🌞 Aproveite a luz natural e desligue luzes desnecessárias.\n"
            "❄️ Ajuste a temperatura do ar-condicionado para 23ºC.\n\n"
            "📲 Veja mais dicas no app **SmartVolt**.";
      } else if (question == "Quais os benefícios da energia solar?") {
        _answer =
            "🌞 **Vantagens da Energia Solar:**\n\n"
            "💰 **Economia** – Redução na conta de luz.\n"
            "🌍 **Sustentabilidade** – Energia limpa e renovável.\n"
            "⚡ **Autonomia** – Menos dependência da rede elétrica.\n"
            "📈 **Valorização** – Seu imóvel pode valer mais no mercado.\n\n"
            "📲 Saiba mais no site oficial do SmartVolt.";
      }
    });
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
      ),
    );
  }

  // Método para criar botões estilizados como cartões
  Widget _buildQuestionCard(String question, IconData icon) {
    return GestureDetector(
      onTap: () {
        _showAnswer(question);
        // Aqui, ao tocar no cartão, você pode navegar para outra página, por exemplo, Alertas
        //  pode usar o Navigator.pushNamed() para navegar para outra tela:
        // Navigator.pushNamed(context, '/alerts');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
