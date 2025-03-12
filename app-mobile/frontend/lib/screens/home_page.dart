import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
  String selectedFilter = "Dia"; // Filtro padrão

  // Dados dinâmicos para os cartões e gráficos
  final Map<String, List<double>> realData = {
    "Dia": [12, 13, 143], // Consumo, Produção, Valor estimado (R$)
    "Semana": [75, 78, 870],
    "Mês": [320, 350, 3600],
  };

  final Map<String, List<double>> predictedData = {
    "Dia": [14, 12],
    "Semana": [80, 73],
    "Mês": [330, 340],
  };

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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFilterButton("Dia"),
                  _buildFilterButton("Semana"),
                  _buildFilterButton("Mês"),
                ],
              ),

              const SizedBox(height: 20),

              // Cartões de Consumo e Produção com valores dinâmicos
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      icon: Icons.flash_on,
                      title: "Consumo",
                      value: "${realData[selectedFilter]![0]} kWh",
                      price:
                          "R\$ ${(realData[selectedFilter]![0] * 1.2).toStringAsFixed(2)}",
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCard(
                      icon: Icons.wb_sunny,
                      title: "Produção",
                      value: "${realData[selectedFilter]![1]} kWh",
                      price:
                          "R\$ ${(realData[selectedFilter]![1] * 1.2).toStringAsFixed(2)}",
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Cartão de Estimativa de Fatura com valores dinâmicos
              _buildCard(
                icon: Icons.attach_money,
                title: "Valor estimado da próxima fatura",
                value: "${realData[selectedFilter]![2]} kWh",
                price: "R\$ ${realData[selectedFilter]![2]}",
                color: Colors.purple,
                fullWidth: true,
              ),

              const SizedBox(height: 20),

              // Gráficos Comparativos (lado a lado)
              Row(
                children: [
                  Expanded(
                    child: _buildComparisonCard(
                      title: "Consumo vs Geração (Real)",
                      data: realData,
                      color1: Colors.orange,
                      color2: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildComparisonCard(
                      title: "Consumo vs Geração (Previsto)",
                      data: predictedData,
                      color1: Colors.blue,
                      color2: Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Alerta de Produção (Mantido no Final)
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

  // ✅ Criar botões de filtro para selecionar Dia, Semana ou Mês
  Widget _buildFilterButton(String filter) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selectedFilter == filter ? Colors.purple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: selectedFilter == filter ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ✅ Criar cartões de consumo, produção e estimativa
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

  // ✅ Criar cartões com gráficos comparativos
  Widget _buildComparisonCard({
    required String title,
    required Map<String, List<double>> data,
    required Color color1,
    required Color color2,
  }) {
    return Container(
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
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 150, child: _buildBarChart(data, color1, color2)),
        ],
      ),
    );
  }

  // ✅ Criar gráfico de barras
  Widget _buildBarChart(
    Map<String, List<double>> data,
    Color color1,
    Color color2,
  ) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        barGroups: _generateBarGroups(data, color1, color2),
      ),
    );
  }

  // ✅ Gerar os dados para o gráfico de barras
  List<BarChartGroupData> _generateBarGroups(
    Map<String, List<double>> data,
    Color color1,
    Color color2,
  ) {
    List<double> values = data[selectedFilter]!;
    return [
      BarChartGroupData(
        x: 0,
        barRods: [BarChartRodData(toY: values[0], color: color1, width: 20)],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData(toY: values[1], color: color2, width: 20)],
      ),
    ];
  }
}
