import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   title: const Text("Home", style: TextStyle(color: Colors.black)),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saudações e nome do usuário
              const Text(
                "Olá!",
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const Text(
                "Glauco Gonçalves",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Segunda 18, 2025",
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),

              const SizedBox(height: 20),

              // Seletor de período
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ChoiceChip(
                    label: const Text("Hoje"),
                    selected: true,
                    selectedColor: Colors.purple,
                    labelStyle: const TextStyle(color: Colors.white),
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text("Essa semana"),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  ChoiceChip(
                    label: const Text("Esse mês"),
                    selected: false,
                    onSelected: (_) {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Cartões de Consumo e Produção
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      icon: Icons.flash_on,
                      title: "Consumo",
                      value: "12 kWh",
                      price: "R\$ 101,00",
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCard(
                      icon: Icons.wb_sunny,
                      title: "Produção",
                      value: "13 kWh",
                      price: "R\$ 103,00",
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Cartão de Estimativa de Fatura
              _buildCard(
                icon: Icons.attach_money,
                title: "Valor estimado da próxima fatura",
                value: "127 kWh",
                price: "R\$ 143,00",
                color: Colors.purple,
                fullWidth: true,
              ),

              const SizedBox(height: 20),

              // Alerta de Produção
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: const Text(
                        "Atenção! Você está produzindo menos que o esperado. Avalie economizar!",
                        style: TextStyle(fontSize: 16),
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

  // Widget para construir os cartões de consumo, produção e estimativa de fatura
  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
    required String price,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      margin: const EdgeInsets.symmetric(vertical: 5),
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
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
