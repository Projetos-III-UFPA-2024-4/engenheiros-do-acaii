import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class ConsumptionPage extends StatefulWidget {
  const ConsumptionPage({super.key});

  @override
  ConsumptionPageState createState() => ConsumptionPageState();
}

class ConsumptionPageState extends State<ConsumptionPage> {
  String selectedFilter = "Dia"; // Filtro padrão
  bool isLoading = false;
  List<double> consumptionData = [];
  List<double> generationData = [];
  List<double> savingsData = [];

  @override
  void initState() {
    super.initState();
    _fetchData('diario'); // Carregar dados iniciais (diário)
  }

  // Método para fazer a requisição e carregar os dados da API
  Future<void> _fetchData(String periodo) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Requisição para consumo
      final consumptionResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/consumo-real?periodo=$periodo'),
      );

      // Requisição para geração
      final generationResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/producao-real?periodo=$periodo'),
      );

      if (consumptionResponse.statusCode == 200 && generationResponse.statusCode == 200) {
        final consumptionDataJson = jsonDecode(consumptionResponse.body);
        final generationDataJson = jsonDecode(generationResponse.body);

        // Verifique se a chave 'registros' existe e tem dados para consumo e geração
        if (consumptionDataJson['registros'] != null && consumptionDataJson['registros'].isNotEmpty &&
            generationDataJson['registros'] != null && generationDataJson['registros'].isNotEmpty) {
          setState(() {
            // Acumular os dados por hora para consumo e geração
            consumptionData = _aggregateDataByHour(consumptionDataJson['registros'], 'consumoTotal');
            generationData = _aggregateDataByHour(generationDataJson['registros'], 'energia_solar_kw'); // Coluna de geração
            savingsData = _calculateSavings(consumptionData, generationData); // Calculando economia (geração - consumo)
          });
        } else {
          setState(() {
            consumptionData = [];
            generationData = [];
            savingsData = [];
          });
        }
      } else {
        print("Erro ao carregar dados: ${consumptionResponse.statusCode}, ${generationResponse.statusCode}");
        setState(() {
          consumptionData = [];
          generationData = [];
          savingsData = [];
        });
      }
    } catch (e) {
      print("Erro na requisição: $e");
      setState(() {
        consumptionData = [];
        generationData = [];
        savingsData = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para agrupar os dados por hora e converter de Wh para kWh
  List<double> _aggregateDataByHour(List<dynamic> registros, String columnName) {
    List<double> hourlyData = List.filled(24, 0.0); // Inicializa uma lista com 24 horas

    for (var registro in registros) {
      DateTime time;
      
      // Verificando se 'timestamp' não é nulo antes de tentar converter
      if (registro['timestamp'] != null) {
        time = DateTime.parse(registro['timestamp']); // Converte apenas se não for nulo
      } else {
        continue; // Se o timestamp for nulo, pula o registro
      }

      int hour = time.hour;

      // Se o valor for válido, acumule na hora correspondente e converta para kWh
      if (registro[columnName] != null) {
        hourlyData[hour] += (registro[columnName] as num).toDouble() / 1000; // Dividido por 1000 para converter Wh para kWh
      }
    }
    return hourlyData;
  }

  // Função para calcular a economia como diferença entre geração e consumo
  List<double> _calculateSavings(List<double> consumption, List<double> generation) {
    List<double> savings = [];
    for (int i = 0; i < 24; i++) {
      savings.add(generation[i] - consumption[i]); // Economia = Geração - Consumo
    }
    return savings;
  }

  // Função para atualizar o filtro e recarregar os dados
  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    String periodo = '';
    if (filter == "Dia") periodo = 'diario';
    else if (filter == "Semana") periodo = 'semanal';
    else if (filter == "Mês") periodo = 'mensal';

    _fetchData(periodo);
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                          value: _getTotal(consumptionData) == 0.0
                              ? "Sem dados"
                              : "${_getTotal(consumptionData)} kWh",
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoCard(
                          title: "Economia",
                          value: _getTotal(savingsData) == 0.0
                              ? "Sem dados"
                              : "${_getTotal(savingsData)} kWh",
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

  // Criar os botões de filtro
  Widget _buildFilterButton(String filter) {
    return GestureDetector(
      onTap: () => _onFilterChanged(filter),
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

  // Criar os cartões informativos
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

  // Gráfico de Barras Responsivo ajustado para o número de dados disponíveis
  Widget _buildResponsiveBarChart() {
    // Verifique se as listas de consumo, geração e economia não estão vazias
    if (consumptionData.isEmpty || generationData.isEmpty || savingsData.isEmpty) {
      return const Center(child: Text("Sem dados para exibir"));
    }

    // Limitar o número de barras ao tamanho dos dados
    int numBars = consumptionData.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        return BarChart(
          BarChartData(
            barGroups: List.generate(numBars, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: consumptionData[index],
                    color: Colors.red,
                    width: 8, // Reduzindo a largura das barras
                    borderRadius: BorderRadius.circular(6),
                  ),
                  BarChartRodData(
                    toY: savingsData[index],
                    color: Colors.green,
                    width: 8, // Reduzindo a largura das barras
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
                    int index = value.toInt();
                    // Exibir rótulos como 1h, 2h, 13h
                    return Text(
                      "$index",
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

  // Método para calcular o total de energia consumida ou economizada
  double _getTotal(List<double> values) {
    if (values.isEmpty) {
      return 0.0; // Retorna 0.0 se a lista estiver vazia
    }
    return values.reduce((a, b) => a + b);
  }
}
