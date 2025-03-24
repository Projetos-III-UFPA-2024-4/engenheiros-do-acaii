import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:frontend/api/consumo_service.dart';

/// Modelo para representar cada registro de consumo
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

  /// Lista dos registros retornados pela API
  List<RegistroConsumo> _listaConsumo = [];
  List<RegistroConsumo> _listaPrevisao = [];

  /// Dados agregados para o gráfico de linha
  List<double> aggregatedData = [];
  List<double> aggregatedForecastData = [];

  /// Rótulos para o eixo X do gráfico
  List<String> xLabels = [];
  List<String> xForecastLabels = [];

  /// Total previsto retornado pela API de previsão (usado no card)
  double _forecastTotal = 0.0;

  /// Valor (em R$) por kWh
  final double valorKWh = 0.938;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Converte o filtro para o parâmetro esperado pela API
  String _getApiPeriodo(String filter) {
    switch (filter) {
      case "Dia":
        return "diario";
      case "Semana":
        return "semanal";
      case "Mês":
        return "mensal";
      default:
        return "recente";
    }
  }

  /// Busca os dados de consumo e, se aplicável, os dados de previsão
  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final periodo = _getApiPeriodo(selectedFilter);
      final response = await ConsumoService.getConsumoReal(periodo);
      final registros = response["registros"] ?? [];

      // Converte os registros em objetos RegistroConsumo e divide por 1000 para converter Wh para kWh
      List<RegistroConsumo> lista = registros.map<RegistroConsumo>((item) {
        final kw = (item["consumoTotal"] ?? 0.0) / 1000; // Divide por 1000
        final tempoStr = item["timestamp"] ?? "";
        DateTime tempo = DateTime.tryParse(tempoStr) ?? DateTime.now();
        return RegistroConsumo(kw: (kw as num).toDouble(), tempo: tempo);
      }).toList();

      final response2 = await ConsumoService.getPrevisaoConsumo(periodo);
      final registros2 = response2["registros"] ?? [];

      // Converte os registros de previsão em objetos RegistroConsumo e divide por 1000 para converter Wh para kWh
      List<RegistroConsumo> listaPrevisao = registros2.map<RegistroConsumo>((item) {
        final kw = (item["consumo"] ?? 0.0) / 1000; // Divide por 1000
        final tempoStr = item["timestamp"] ?? "";
        DateTime tempo = DateTime.tryParse(tempoStr) ?? DateTime.now();
        return RegistroConsumo(kw: (kw as num).toDouble(), tempo: tempo);
      }).toList();

      // Calcula o total de previsão
      double forecastTotal = listaPrevisao.fold(0.0, (sum, item) => sum + item.kw);

      setState(() {
        _listaConsumo = lista;
        _listaPrevisao = listaPrevisao;
        _forecastTotal = forecastTotal;
      });

      _aggregateData();
      _aggregateForecastData();
    } catch (e) {
      print("Erro ao buscar dados: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Agrega os dados de consumo com base na última medição.
  /// - "Dia": As 24 horas anteriores à última medição.
  /// - "Semana": Os 7 dias anteriores à data da última medição.
  /// - "Mês": Os 30 dias anteriores à data da última medição.
  void _aggregateData() {
    if (_listaConsumo.isEmpty) {
      setState(() {
        aggregatedData = [];
        xLabels = [];
      });
      return;
    }

    // Determina a última medição
    DateTime lastMeasurement = _listaConsumo.reduce(
      (a, b) => a.tempo.isAfter(b.tempo) ? a : b,
    ).tempo;

    if (selectedFilter == "Dia") {
      // Define o início como a última medição menos 23 horas
      DateTime startTime = lastMeasurement.subtract(Duration(hours: 23));
      List<double> data = [];
      List<String> labels = [];

      // Itera sobre as 24 horas a partir do startTime
      for (int i = 0; i < 24; i++) {
        DateTime intervalStart = startTime.add(Duration(hours: i));
        DateTime intervalEnd = startTime.add(Duration(hours: i + 1));
        double sum = 0.0;

        // Soma os valores dentro do intervalo de hora
        for (var reg in _listaConsumo) {
          if ((reg.tempo.isAtSameMomentAs(intervalStart) ||
                  reg.tempo.isAfter(intervalStart)) &&
              reg.tempo.isBefore(intervalEnd)) {
            sum += reg.kw;
          }
        }

        // Adiciona apenas se houver dados no intervalo
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
      DateTime lastDate = DateTime(lastMeasurement.year, lastMeasurement.month,
          lastMeasurement.day);
      DateTime startDate = lastDate.subtract(Duration(days: 6));
      List<double> data = List.filled(7, 0.0);
      List<String> labels = [];

      for (int i = 0; i < 7; i++) {
        DateTime day = startDate.add(Duration(days: i));
        double sum = 0.0;
        for (var reg in _listaConsumo) {
          DateTime regDate = DateTime(
              reg.tempo.year, reg.tempo.month, reg.tempo.day);
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
      // Define o início como o primeiro dia do mês da última medição
      DateTime startDate = DateTime(lastMeasurement.year, lastMeasurement.month, 1);
      // Define o fim como o último dia do mês da última medição
      DateTime endDate = DateTime(lastMeasurement.year, lastMeasurement.month + 1, 0);
      int daysInMonth = endDate.day;

      List<double> data = List.filled(daysInMonth, 0.0);
      List<String> labels = [];

      for (int i = 0; i < daysInMonth; i++) {
        DateTime day = startDate.add(Duration(days: i));
        double sum = 0.0;
        for (var reg in _listaConsumo) {
          DateTime regDate =
              DateTime(reg.tempo.year, reg.tempo.month, reg.tempo.day);
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

  /// Agrega os dados de previsão para o mês da última previsão
  void _aggregateForecastData() {
  if (_listaPrevisao.isEmpty || _listaConsumo.isEmpty) {
    setState(() {
      aggregatedForecastData = [];
      xForecastLabels = [];
    });
    return;
  }

  // Determina a última medição
  DateTime lastMeasurement = _listaConsumo.reduce(
    (a, b) => a.tempo.isAfter(b.tempo) ? a : b,
  ).tempo;

  // Define o início como o primeiro dia do mês da última medição
  DateTime startDate = DateTime(lastMeasurement.year, lastMeasurement.month, 1);
  // Define o fim como o último dia do mês da última medição
  DateTime endDate = DateTime(lastMeasurement.year, lastMeasurement.month + 1, 0);
  int daysInMonth = endDate.day;

  List<double> data = List.filled(daysInMonth, 0.0);
  List<String> labels = [];

  for (int i = 0; i < daysInMonth; i++) {
    DateTime day = startDate.add(Duration(days: i));
    double sum = 0.0;

    // Verifica se o dia já possui medições reais
    bool hasRealMeasurement = _listaConsumo.any((reg) {
      DateTime regDate = DateTime(reg.tempo.year, reg.tempo.month, reg.tempo.day);
      return regDate == day;
    });

    // Se o dia já possui medições reais, define o valor como 0
    if (hasRealMeasurement) {
      data[i] = 0.0;
    } else {
      // Caso contrário, soma os valores de previsão para o dia
      for (var reg in _listaPrevisao) {
        DateTime regDate = DateTime(reg.tempo.year, reg.tempo.month, reg.tempo.day);
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

  /// Constrói um botão para seleção do filtro
  Widget _buildFilterButton(String filter) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
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

  /// Card de gastos estimados com base no consumo total
  Widget _buildGainsCard() {
    double totalConsumption = aggregatedData.fold(0.0, (soma, valor) => soma + valor);
    double gastos = totalConsumption * valorKWh;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2)
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
                    color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                "R\$ ${gastos.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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

  /// Card informativo genérico (para consumo atual e previsão)
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
              spreadRadius: 2)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontSize: 16, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Constrói o gráfico de linha com dados agregados e com menos rótulos para evitar sobreposição
  Widget _buildLineChart() {
    if (aggregatedData.isEmpty) {
      return const Center(child: Text("Sem dados para exibir"));
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
                int index = value.toInt();
                if (index < 0 || index >= xLabels.length) {
                  return const SizedBox.shrink();
                }
                // Para evitar sobreposição:
                if (selectedFilter == "Dia" && index % 2 != 0) {
                  return const SizedBox.shrink();
                }
                if (selectedFilter == "Mês" && index % 5 != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(xLabels[index],
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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

  /// Constrói o gráfico de linha para os dados de previsão
  Widget _buildForecastLineChart() {
    if (aggregatedForecastData.isEmpty) {
      return const Center(child: Text("Sem dados de previsão para exibir"));
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
                int index = value.toInt();
                if (index < 0 || index >= xForecastLabels.length) {
                  return const SizedBox.shrink();
                }
                // Para evitar sobreposição:
                if (index % 5 != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(xForecastLabels[index],
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
  double totalConsumption = aggregatedData.fold(0.0, (a, b) => a + b);
  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      title: const Text(
        "Consumo de Energia",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtros: Dia, Semana, Mês
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
                // Cartões para consumo atual e previsão
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
                // Gráfico de linha para consumo atual
                Expanded(child: _buildLineChart()),
                const SizedBox(height: 20),
                // Botão "Ver previsões do mês" (aparece apenas nos filtros "Dia" e "Semana")
                if (selectedFilter != "Mês")
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFilter = "Mês"; // Muda para o filtro "Mês"
                        });
                        _fetchData(); // Atualiza os dados
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                // Gráfico de linha para previsão (aparece apenas no filtro "Mês")
                if (selectedFilter == "Mês")
                  Expanded(child: _buildForecastLineChart()),
              ],
            ),
          ),
  );
}
}