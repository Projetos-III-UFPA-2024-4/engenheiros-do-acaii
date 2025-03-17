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

            // Gráfico de Barras - Consumo e Economia
            const Text(
              "Consumo vs Economia de Energia",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildResponsiveBarChart()),
          ],
        ),
      ),
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

  // ✅ Gráfico de Barras Responsivo ajustado para parecer com a Geração
  Widget _buildResponsiveBarChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BarChart(
          BarChartData(
            barGroups: List.generate(consumptionData[selectedFilter]!.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: consumptionData[selectedFilter]![index],
                    color: Colors.red,
                    width: 16, // Mantendo a mesma largura das barras da geração
                    borderRadius: BorderRadius.circular(6),
                  ),
                  BarChartRodData(
                    toY: savingsData[selectedFilter]![index],
                    color: Colors.green,
                    width: 16, // Mantendo a mesma largura das barras da geração
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              );
            }),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              },
            ),
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
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _getLabelForX(value.toInt()),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ Definir rótulos do eixo X
  String _getLabelForX(int index) {
    return ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"][index];
  }

  // ✅ Método para calcular o total de energia consumida ou economizada
  double _getTotal(List<double> values) {
    return values.reduce((a, b) => a + b);
  }
}
