import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({super.key});

  @override
  ConsumptionPageState createState() => ConsumptionPageState();
}

class ConsumptionPageState extends State<ConsumptionPage> {
  String selectedFilter = "Dia"; // Filtro padrão

  // Dados para consumo e economia
  final Map<String, List<double>> consumptionData = {
    "Dia": [10, 12, 14, 16, 18, 14, 12],
    "Semana": [50, 55, 60, 52, 58, 62, 59],
    "Mês": [200, 220, 210, 230, 215, 205, 240],
  };

  final Map<String, List<double>> savingsData = {
    "Dia": [3, 4, 5, 6, 7, 5, 4],
    "Semana": [15, 18, 20, 14, 19, 22, 21],
    "Mês": [70, 80, 85, 90, 95, 100, 110],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Consumo de Energia",
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

            // Cartões informativos
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: "Consumo Total",
                    value: "${_getTotal(consumptionData[selectedFilter]!)} kWh",
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoCard(
                    title: "Economia",
                    value: "${_getTotal(savingsData[selectedFilter]!)} kWh",
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Gráfico de Linhas - Consumo e Economia
            const Text(
              "Consumo vs Economia de Energia",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildLineChart()),
          ],
        ),
      ),
    );
  }

  // ✅ Gráfico de Linhas (Consumo vs Economia)
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  _getLabelForX(value.toInt()),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          // Linha do Consumo
          LineChartBarData(
            spots: _generateSpots(consumptionData[selectedFilter]!),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
          // Linha da Economia
          LineChartBarData(
            spots: _generateSpots(savingsData[selectedFilter]!),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  // ✅ Gerar os pontos para o gráfico de linhas
  List<FlSpot> _generateSpots(List<double> values) {
    return List.generate(
      values.length,
      (index) => FlSpot(index.toDouble(), values[index]),
    );
  }

  // ✅ Criar os botões de filtro
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

  // ✅ Criar os cartões informativos
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  // ✅ Método para calcular o total de energia consumida ou economizada
  double _getTotal(List<double> values) {
    return values.reduce((a, b) => a + b);
  }

  // ✅ Definir rótulos do eixo X
  String _getLabelForX(int index) {
    Map<String, List<String>> labelsMap = {
      "Dia": ["6AM", "7AM", "8AM", "9AM", "10AM", "12PM", "1PM"],
      "Semana": ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"],
      "Mês": ["1", "5", "10", "15", "20", "25", "30"],
    };

    return labelsMap[selectedFilter]![index];
  }
}
