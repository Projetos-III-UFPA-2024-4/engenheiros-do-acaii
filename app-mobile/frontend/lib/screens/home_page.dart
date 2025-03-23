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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

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

  // Método para fazer a requisição e carregar os dados da API
  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final periodo = _getApiPeriodo(selectedFilter);
      final consumptionResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/consumo-real?periodo=$periodo'),
      );
      final generationResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/producao-real?periodo=$periodo'),
      );
      final predictedConsumptionResponse = await http.get(
        Uri.parse('http://localhost:5000/servicos/crud-dados/previsao-consumo?periodo=$periodo'),
      );
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

        setState(() {
          realConsumptionData = _aggregateDataByHour(consumptionDataJson['registros'] ?? [], 'consumoTotal', isConsumption: true);
          realGenerationData = _aggregateDataByHour(generationDataJson['registros'] ?? [], 'energia_solar_kw', isConsumption: false);
          predictedConsumptionData = _aggregateDataByHour(predictedConsumptionDataJson['registros'] ?? [], 'consumo', isConsumption: true);
          predictedGenerationData = _aggregateDataByHour(predictedGenerationDataJson['registros'] ?? [], 'geracao (kwh)', isConsumption: false);

          totalProduction = realGenerationData.fold(0.0, (sum, value) => sum + value);
        });
      } else {
        print("Erro ao carregar dados: ${consumptionResponse.statusCode}, ${generationResponse.statusCode}");
      }
    } catch (e) {
      print("Erro na requisição: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para converter de Wh para kWh (se necessário) e retornar os valores
  List<double> _aggregateDataByHour(List<dynamic> registros, String columnName, {bool isConsumption = false}) {
    List<double> values = [];

    for (var registro in registros) {
      // Se o valor for nulo, considere como 0
      double value = registro[columnName] != null ? (registro[columnName] as num).toDouble() : 0.0;

      // Se for consumo, converta de Wh para kWh
      if (isConsumption) {
        value /= 1000; // Converte de Wh para kWh
      }

      // Adiciona o valor à lista
      values.add(value);
    }

    return values;
  }

   @override
Widget build(BuildContext context) {
  // Dados agregados para os cartões
  double consumoReal = realConsumptionData.isNotEmpty ? realConsumptionData.reduce((sum, value) => sum + value) : 0.0;
  double geracaoReal = realGenerationData.isNotEmpty ? realGenerationData.reduce((sum, value) => sum + value) : 0.0;
  double previsaoConsumo = predictedConsumptionData.isNotEmpty ? predictedConsumptionData.reduce((sum, value) => sum + value) : 0.0;
  double previsaoGeracao = predictedGenerationData.isNotEmpty ? predictedGenerationData.reduce((sum, value) => sum + value) : 0.0;

  // Cálculo do valor estimado da fatura (consumo real - produção real)
  double diferencaConsumoProducao = consumoReal - geracaoReal;
  double valorEstimadoFatura = diferencaConsumoProducao * kWhRate;

  // Se a produção for maior que o consumo, o valor da fatura é zero
  if (diferencaConsumoProducao < 0) {
    diferencaConsumoProducao = 0.0;
    valorEstimadoFatura = 0.0;
  }

  // Texto dinâmico para o cartão de estimativa da fatura
  String textoFatura;
  switch (selectedFilter) {
    case "Dia":
      textoFatura = "Valor estimado da fatura de hoje";
      break;
    case "Semana":
      textoFatura = "Valor estimado da fatura dos últimos 7 dias";
      break;
    case "Mês":
      textoFatura = "Valor estimado da fatura deste mês";
      break;
    default:
      textoFatura = "Valor estimado da próxima fatura";
  }

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
                    value: "${consumoReal.toStringAsFixed(2)} kWh", // Duas casas decimais
                    price: "R\$ ${(consumoReal * kWhRate).toStringAsFixed(2)}", // Duas casas decimais
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCard(
                    icon: Icons.wb_sunny,
                    title: "Produção",
                    value: "${geracaoReal.toStringAsFixed(2)} kWh", // Duas casas decimais
                    price: "R\$ ${(geracaoReal * kWhRate).toStringAsFixed(2)}", // Duas casas decimais
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Cartão de Estimativa de Fatura com valores dinâmicos
            _buildCard(
              icon: Icons.attach_money,
              title: textoFatura, // Texto dinâmico
              value: "${diferencaConsumoProducao.toStringAsFixed(2)} kWh", // Diferença entre consumo e produção
              price: "R\$ ${valorEstimadoFatura.toStringAsFixed(2)}", // Valor estimado da fatura
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
                      "Dia": [consumoReal, geracaoReal],
                      "Semana": [consumoReal, geracaoReal],
                      "Mês": [consumoReal, geracaoReal],
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
                      "Dia": [previsaoConsumo, previsaoGeracao],
                      "Semana": [previsaoConsumo, previsaoGeracao],
                      "Mês": [previsaoConsumo, previsaoGeracao],
                    },
                    color1: Colors.orange,
                    color2: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // // Alerta de Produção
            // Container(
            //   padding: const EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.yellow.shade100,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.warning, color: Colors.orange, size: 30),
            //       const SizedBox(width: 10),
            //       Expanded(
            //         child: const Text(
            //           "Atenção! Você está produzindo menos que o esperado. Avalie economizar!",
            //           style: TextStyle(fontSize: 16),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
        _fetchData(); // Recarrega os dados ao mudar o filtro
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
    List<double> values = data[selectedFilter] ?? [0.0, 0.0]; // Use valores padrão se o filtro não estiver presente
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: values.isNotEmpty ? values[0] : 0.0, // Verifica se há dados
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
            toY: values.length > 1 ? values[1] : 0.0, // Verifica se há dados
            color: color2,
            width: 40,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    ];
  }
}