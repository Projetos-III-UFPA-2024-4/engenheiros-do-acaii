import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> pessoas;

  @override
  void initState() {
    super.initState();
    pessoas = ApiService.buscarPessoas(); // Chama a API ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<List<dynamic>>(
        future: pessoas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar dados: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum dado encontrado."));
          } else {
            var pessoa = snapshot.data![0]; // Pegando a primeira pessoa da lista

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Olá!", style: TextStyle(fontSize: 20, color: Colors.black54)),
                  Text(
                    pessoa["nome"] ?? "Sem Nome",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("Segunda 18, 2025", style: TextStyle(fontSize: 16, color: Colors.black45)),
                  const SizedBox(height: 20),

                  // Seletor de período
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildChoiceChip("Hoje", true),
                      _buildChoiceChip("Essa semana", false),
                      _buildChoiceChip("Esse mês", false),
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
                          value: pessoa['consumoTotal']?.toString() ?? "N/A",
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
                  _buildAlerta(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Widget para construir os ChoiceChips
  Widget _buildChoiceChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.purple,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      onSelected: (_) {},
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 10),
          Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget para construir o alerta de produção
  Widget _buildAlerta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 30),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Atenção! Você está produzindo menos que o esperado. Avalie economizar!",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
