import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GenerationPage extends StatefulWidget {
  const GenerationPage({super.key});

  @override
  GenerationPageState createState() => GenerationPageState();
}

class GenerationPageState extends State<GenerationPage> {
  String selectedFilter = "Dia"; // Filtro padrão
  bool showPredictions = false; // Controle da exibição das previsões
  final double valorKWh = 0.75;

  // Dados para os diferentes filtros
  final Map<String, List<double>> dataMap = {
    "Dia": [2, 4, 6, 7, 10, 7, 3],
    "Semana": [12, 15, 18, 14, 20, 22, 19],
    "Mês": [100, 120, 130, 110, 140, 150, 135],
  };

  final Map<String, List<double>> predictionMap = {
    "Dia": [3, 5, 7, 8, 11, 8, 4],
    "Semana": [13, 16, 19, 15, 21, 23, 20],
    "Mês": [105, 125, 135, 115, 145, 155, 140],
  };

  // Dados de Consumo e Economia
  final Map<String, List<double>> consumptionData = {
    "Dia": [8, 10, 12, 14, 16, 12, 10],
    "Semana": [40, 45, 50, 42, 48, 52, 49],
    "Mês": [160, 180, 170, 190, 175, 165, 200],
  };

  final Map<String, List<double>> savingsData = {
    "Dia": [2, 3, 4, 5, 6, 4, 3],
    "Semana": [12, 15, 18, 13, 16, 20, 19],
    "Mês": [60, 70, 75, 80, 85, 90, 95],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Geração de Energia",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtros para o gráfico
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton("Dia"),
                _buildFilterButton("Semana"),
                _buildFilterButton("Mês"),
              ],
            ),
            const SizedBox(height: 20),
            _buildGainsCard(),
            const SizedBox(height: 10),

            // Cartões informativos
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: "Produção Atual",
                    value: "${_getTotal(dataMap[selectedFilter]!)} kWh",
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    title: "Previsão do Modelo",
                    value: "${_getTotal(predictionMap[selectedFilter]!)} kWh",
                    color: Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Gráfico de Barras - Produção ao longo do tempo
            const Text(
              "Produção ao Longo do Tempo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildBarChart()),

            const SizedBox(height: 10),
            // Botão para mostrar previsões
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showPredictions = !showPredictions;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: Text(
                  showPredictions ? "Ocultar Previsões" : "Ver Previsões",
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Card de Ganhos Destacado
  Widget _buildGainsCard() {
    double totalEnergia = _getTotal(dataMap[selectedFilter]!);
    double ganhos = totalEnergia * valorKWh;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[400],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, size: 40, color: Colors.white),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ganhos Estimados",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "R\$ ${ganhos.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Com base em ${totalEnergia.toStringAsFixed(1)} kWh gerados",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Método para criar os cartões informativos
  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
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
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para criar botões de filtro
  Widget _buildFilterButton(String filter) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
          showPredictions = false;
          // Resetar previsões ao trocar de filtro
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

  // Gráfico de Barras - Produção ao longo do tempo
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    _getLabelForX(value.toInt()),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: _generateBarGroups(),
      ),
    );
  }

  // Gerando os dados do gráfico de barras com previsões
  List<BarChartGroupData> _generateBarGroups() {
    List<double> data = dataMap[selectedFilter]!;
    List<double> predictions = predictionMap[selectedFilter]!;

    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: Colors.greenAccent,
            width: 16,
            borderRadius: BorderRadius.circular(6),
          ),
          if (showPredictions)
            BarChartRodData(
              toY: predictions[index],
              color: Colors.amber,
              width: 16,
              borderRadius: BorderRadius.circular(6),
            ),
        ],
      );
    });
  }

  // Método para definir rótulos do eixo X
  String _getLabelForX(int index) {
    Map<String, List<String>> labelsMap = {
      "Dia": ["6AM", "7AM", "8AM", "9AM", "10AM", "12PM", "1PM"],
      "Semana": ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"],
      "Mês": ["1", "5", "10", "15", "20", "25", "30"],
    };
    return labelsMap[selectedFilter]![index];
  }

  // Método para calcular o total de energia gerada
  double _getTotal(List<double> values) {
    return values.reduce((a, b) => a + b);
  }
}
