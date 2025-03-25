import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/api/consumo_service.dart';

class RegistroConsumo {
  final double kw;
  final DateTime tempo;

  RegistroConsumo({required this.kw, required this.tempo});
}

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({Key? key}) : super(key: key);

  @override
  ConsumptionPageState createState() => ConsumptionPageState();
}

class ConsumptionPageState extends State<ConsumptionPage> {
  String selectedFilter = "Dia";
  bool isLoading = false;
  List<RegistroConsumo> _listaConsumo = [];
  List<RegistroConsumo> _listaPrevisao = [];
  List<double> aggregatedData = [];
  List<double> aggregatedForecastData = [];
  List<String> xLabels = [];
  List<String> xForecastLabels = [];
  double _forecastTotal = 0.0;
  final double valorKWh = 0.938;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = 
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  String _getApiPeriodo(String filter) {
    switch (filter) {
      case "Dia": return "diario";
      case "Semana": return "semanal";
      case "Mês": return "mensal";
      default: return "recente";
    }
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      final periodo = _getApiPeriodo(selectedFilter);
      final [response, response2] = await Future.wait([
        ConsumoService.getConsumoReal(periodo),
        ConsumoService.getPrevisaoConsumo(periodo),
      ]);

      setState(() {
        _listaConsumo = (response["registros"] ?? []).map<RegistroConsumo>((item) {
          return RegistroConsumo(
            kw: (item["consumoTotal"] ?? 0.0) / 1000,
            tempo: DateTime.tryParse(item["timestamp"] ?? "") ?? DateTime.now(),
          );
        }).toList();

        _listaPrevisao = (response2["registros"] ?? []).map<RegistroConsumo>((item) {
          return RegistroConsumo(
            kw: (item["consumo"] ?? 0.0) / 1000,
            tempo: DateTime.tryParse(item["timestamp"] ?? "") ?? DateTime.now(),
          );
        }).toList();

        _forecastTotal = _listaPrevisao.fold(0.0, (sum, item) => sum + item.kw);
      });

      _aggregateData();
      _aggregateForecastData();
    } catch (e) {
      print("Erro ao buscar dados: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _aggregateData() {
    if (_listaConsumo.isEmpty) {
      setState(() {
        aggregatedData = [];
        xLabels = [];
      });
      return;
    }

    final lastMeasurement = _listaConsumo.reduce((a, b) => a.tempo.isAfter(b.tempo) ? a : b).tempo;

    if (selectedFilter == "Dia") {
      final startTime = lastMeasurement.subtract(const Duration(hours: 23));
      final data = <double>[];
      final labels = <String>[];

      for (int i = 0; i < 24; i++) {
        final intervalStart = startTime.add(Duration(hours: i));
        final intervalEnd = startTime.add(Duration(hours: i + 1));
        double sum = 0.0;

        for (var reg in _listaConsumo) {
          if (reg.tempo.isAtSameMomentAs(intervalStart) || 
              (reg.tempo.isAfter(intervalStart) && reg.tempo.isBefore(intervalEnd))) {
            sum += reg.kw;
          }
        }

        if (sum > 0) {
          data.add(sum);
          labels.add(DateFormat('HH:mm').format(intervalStart));
        }
      }

      setState(() {
        aggregatedData = data;
        xLabels = labels;
      });
    } else if (selectedFilter == "Semana") {
      final lastDate = DateTime(lastMeasurement.year, lastMeasurement.month, lastMeasurement.day);
      final startDate = lastDate.subtract(const Duration(days: 6));
      final data = List.filled(7, 0.0);
      final labels = <String>[];

      for (int i = 0; i < 7; i++) {
        final day = startDate.add(Duration(days: i));
        double sum = 0.0;
        for (var reg in _listaConsumo) {
          final regDate = DateTime(reg.tempo.year, reg.tempo.month, reg.tempo.day);
          if (regDate == day) {
            sum += reg.kw;
          }
        }
        data[i] = sum;
        labels.add(DateFormat('EEE dd').format(day));
      }

      setState(() {
        aggregatedData = data;
        xLabels = labels;
      });
    } else if (selectedFilter == "Mês") {
      final startDate = DateTime(lastMeasurement.year, lastMeasurement.month, 1);
      final endDate = DateTime(lastMeasurement.year, lastMeasurement.month + 1, 0);
      final daysInMonth = endDate.day;
      final data = List.filled(daysInMonth, 0.0);
      final labels = <String>[];

      for (int i = 0; i < daysInMonth; i++) {
        final day = startDate.add(Duration(days: i));
        double sum = 0.0;
        for (var reg in _listaConsumo) {
          final regDate = DateTime(reg.tempo.year, reg.tempo.month, reg.tempo.day);
          if (regDate == day) {
            sum += reg.kw;
          }
        }
        data[i] = sum;
        labels.add(DateFormat('dd/MM').format(day));
      }

      setState(() {
        aggregatedData = data;
        xLabels = labels;
      });
    }
  }

  void _aggregateForecastData() {
    if (_listaPrevisao.isEmpty || _listaConsumo.isEmpty) {
      setState(() {
        aggregatedForecastData = [];
        xForecastLabels = [];
      });
      return;
    }

    final lastMeasurement = _listaConsumo.reduce((a, b) => a.tempo.isAfter(b.tempo) ? a : b).tempo;
    final startDate = DateTime(lastMeasurement.year, lastMeasurement.month, 1);
    final endDate = DateTime(lastMeasurement.year, lastMeasurement.month + 1, 0);
    final daysInMonth = endDate.day;
    final data = List.filled(daysInMonth, 0.0);
    final labels = <String>[];

    for (int i = 0; i < daysInMonth; i++) {
      final day = startDate.add(Duration(days: i));
      double sum = 0.0;

      final hasRealMeasurement = _listaConsumo.any((reg) {
        final regDate = DateTime(reg.tempo.year, reg.tempo.month, reg.tempo.day);
        return regDate == day;
      });

      if (!hasRealMeasurement) {
        for (var reg in _listaPrevisao) {
          final regDate = DateTime(reg.tempo.year, reg.tempo.month, reg.tempo.day);
          if (regDate == day) {
            sum += reg.kw;
          }
        }
        data[i] = sum;
      }

      labels.add(DateFormat('dd/MM').format(day));
    }

    setState(() {
      aggregatedForecastData = data;
      xForecastLabels = labels;
    });
  }

  Widget _buildFilterButton(String filter) {
    return GestureDetector(
      onTap: () {
        setState(() => selectedFilter = filter);
        _fetchData();
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

  Widget _buildGainsCard() {
    final totalConsumption = aggregatedData.fold(0.0, (a, b) => a + b);
    final gastos = totalConsumption * valorKWh;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                "Gastos Estimados",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "R\$ ${gastos.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Com base em ${totalConsumption.toStringAsFixed(1)} kWh consumidos",
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  Widget _buildLineChart() {
    if (aggregatedData.isEmpty) {
      return const Center(
        child: Text("Sem dados para exibir"),
      );
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= xLabels.length) {
                  return const SizedBox.shrink();
                }
                if (selectedFilter == "Dia" && index % 2 != 0) {
                  return const SizedBox.shrink();
                }
                if (selectedFilter == "Mês" && index % 5 != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    xLabels[index],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              aggregatedData.length,
              (index) => FlSpot(index.toDouble(), aggregatedData[index]),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastLineChart() {
    if (aggregatedForecastData.isEmpty) {
      return const Center(
        child: Text("Sem dados de previsão para exibir"),
      );
    }
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= xForecastLabels.length) {
                  return const SizedBox.shrink();
                }
                if (index % 5 != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    xForecastLabels[index],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              aggregatedForecastData.length,
              (index) => FlSpot(index.toDouble(), aggregatedForecastData[index]),
            ),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalConsumption = aggregatedData.fold(0.0, (a, b) => a + b);
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Consumo de Energia",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _refreshIndicatorKey.currentState?.show(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _fetchData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              title: "Consumo Atual",
                              value: "${totalConsumption.toStringAsFixed(2)} kWh",
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInfoCard(
                              title: "Previsão do Modelo",
                              value: "${_forecastTotal.toStringAsFixed(2)} kWh",
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: _buildLineChart(),
                      ),
                      if (selectedFilter != "Mês") ...[
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => selectedFilter = "Mês");
                              _fetchData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              "Ver previsões do mês",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (selectedFilter == "Mês") ...[
                        const SizedBox(height: 20),
                        Text("Previsões para os próximos dias", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: _buildForecastLineChart(),
                        ),
                      ],
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}