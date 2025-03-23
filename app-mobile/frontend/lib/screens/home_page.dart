import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

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
  bool isLoading = false;

  // Taxa do kWh
  final double kWhRate = 0.938;

  // Dados dinâmicos para os cartões e gráficos
  List<double> realConsumptionData = [];
  List<double> realGenerationData = [];
  List<double> predictedConsumptionData = [];
  List<double> predictedGenerationData = [];
  
  // Variável para armazenar o total de produção
  double totalProduction = 0.0;
  bool isConsumption = false;

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
      // Requisição para consumo real
      final consumptionResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/consumo-real?periodo=$periodo'),
      );

      // Requisição para produção real
      final generationResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/producao-real?periodo=$periodo'),
      );

      // Requisição para previsão de consumo
      final predictedConsumptionResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/previsao-consumo?periodo=$periodo'),
      );

      // Requisição para previsão de produção
      final predictedGenerationResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/previsao-producao?periodo=$periodo'),
      );

      if (consumptionResponse.statusCode == 200 &&
          generationResponse.statusCode == 200 &&
          predictedConsumptionResponse.statusCode == 200 &&
          predictedGenerationResponse.statusCode == 200) {
        final consumptionDataJson = jsonDecode(consumptionResponse.body);
        final generationDataJson = jsonDecode(generationResponse.body);
        final predictedConsumptionDataJson = jsonDecode(predictedConsumptionResponse.body);
        final predictedGenerationDataJson = jsonDecode(predictedGenerationResponse.body);

        // Verifique se a chave 'registros' existe e tem dados
        if (consumptionDataJson['registros'] != null &&
            consumptionDataJson['registros'].isNotEmpty &&
            generationDataJson['registros'] != null &&
            generationDataJson['registros'].isNotEmpty &&
            predictedConsumptionDataJson['registros'] != null &&
            predictedConsumptionDataJson['registros'].isNotEmpty &&
            predictedGenerationDataJson['registros'] != null &&
            predictedGenerationDataJson['registros'].isNotEmpty) {
          setState(() {
            // Pegar os dados reais de consumo e geração
           realConsumptionData = _aggregateDataByHour(consumptionDataJson['registros'], 'consumoTotal', isConsumption: true);
realGenerationData = _aggregateDataByHour(generationDataJson['registros'], 'energia_solar_kw', isConsumption: false);

// Pegar os dados previstos de consumo e geração
predictedConsumptionData = _aggregateDataByHour(predictedConsumptionDataJson['registros'], 'consumo', isConsumption: true);
predictedGenerationData = _aggregateDataByHour(predictedGenerationDataJson['registros'], 'geracao (kwh)', isConsumption: false);

            // Calcular a produção total
            totalProduction = realGenerationData.fold(0.0, (sum, value) => sum + value);
          });
        }
      } else {
        print("Erro ao carregar dados: ${consumptionResponse.statusCode}, ${generationResponse.statusCode}");
        setState(() {
          realConsumptionData = [];
          realGenerationData = [];
          predictedConsumptionData = [];
          predictedGenerationData = [];
        });
      }
    } catch (e) {
      print("Erro na requisição: $e");
      setState(() {
        realConsumptionData = [];
        realGenerationData = [];
        predictedConsumptionData = [];
        predictedGenerationData = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para agrupar os dados por hora e converter de Wh para kWh
  List<double> _aggregateDataByHour(List<dynamic> registros, String columnName, {bool isConsumption = false}) {
  List<double> hourlyData = List.filled(24, 0.0); // Inicializa uma lista com 24 horas

  for (var registro in registros) {
    DateTime time;

    // Verificando se 'tempo' (para produção real) ou 'timestamp' (para os outros) não é nulo antes de tentar converter
    try {
      if (registro['tempo'] != null) {
        time = DateTime.parse(registro['tempo']); // Para a produção real
      } else if (registro['timestamp'] != null) {
        time = DateTime.parse(registro['timestamp']); // Para os outros dados
      } else {
        continue; // Se o timestamp/tempo for nulo, pula o registro
      }
    } catch (e) {
      print("Erro ao parsear o tempo/timestamp: $e");
      continue; // Pula o registro se ocorrer erro ao converter o timestamp
    }

    int hour = time.hour;

    // Se o valor for válido, acumule na hora correspondente
    if (registro[columnName] != null) {
      double value = (registro[columnName] as num).toDouble();
      
      // Se for consumo, converta de Wh para kWh
      if (isConsumption) {
        value /= 1000; // Converte de Wh para kWh apenas para consumo
      }

      // Acumule o valor na hora correspondente
      hourlyData[hour] += value;
    }
  }
  return hourlyData;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      value: "${realConsumptionData.isNotEmpty ? realConsumptionData[0] : 0.0} kWh",
                      price:
                          "R\$ ${(realConsumptionData.isNotEmpty ? realConsumptionData[0] : 0.0) * kWhRate}",
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCard(
                      icon: Icons.wb_sunny,
                      title: "Produção",
                      value: "${totalProduction} kWh",  // Exibe o total de produção
                      price:
                          "R\$ ${totalProduction * kWhRate}",
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Cartão de Estimativa de Fatura com valores dinâmicos
              _buildCard(
                icon: Icons.attach_money,
                title: "Valor estimado da próxima fatura",
                value: "${realConsumptionData.isNotEmpty ? realConsumptionData[0] : 0.0} kWh",
                price: "R\$ ${((predictedGenerationData.isNotEmpty ? predictedGenerationData[0] : 0.0) - (predictedConsumptionData.isNotEmpty ? predictedConsumptionData[0] : 0.0)) * kWhRate}",
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
                      data: {
                        "Dia": [realConsumptionData[0], realGenerationData[0]],
                        "Semana": [realConsumptionData[1], realGenerationData[1]],
                        "Mês": [realConsumptionData[2], realGenerationData[2]],
                      },
                      color1: const Color.fromRGBO(255, 152, 0, 1),
                      color2: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildComparisonCard(
                      title: "Consumo vs Geração (Previsto)",
                      data: {
                        "Dia": [predictedConsumptionData[0], predictedGenerationData[0]],
                        "Semana": [predictedConsumptionData[1], predictedGenerationData[1]],
                        "Mês": [predictedConsumptionData[2], predictedGenerationData[2]],
                      },
                      color1: Colors.orange,
                      color2: Colors.purple,
                    ),
                  ),
                ],
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

  // Criar os botões de filtro
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

  // Criar cartões de consumo, produção e estimativa
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
            color: Colors.grey.withValues(),
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

  // Criar cartões com gráficos comparativos
  Widget _buildComparisonCard({
    required String title,
    required Map<String, List<double>> data,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),
          SizedBox(height: 300, child: _buildBarChart(data, color1, color2)),
        ],
      ),
    );
  }

  // Criar gráfico de barras atualizado
  Widget _buildBarChart(
    Map<String, List<double>> data,
    Color color1,
    Color color2,
  ) {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                List<String> labels = ["Consumo", "Geração"];
                return SideTitleWidget(
                  meta: meta,
                  space: 5,
                  child: Text(
                    labels[value.toInt()],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: _generateBarGroups(data, color1, color2),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(
    Map<String, List<double>> data,
    Color color1,
    Color color2,
  ) {
    List<double> values = data[selectedFilter]!;
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: values[0],
            color: color1,
            width: 40,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: values[1],
            color: color2,
            width: 40,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    ];
  }
}
