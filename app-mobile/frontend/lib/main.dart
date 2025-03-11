import 'package:flutter/material.dart';
import 'package:frontend/screens/alert.dart';
import 'package:frontend/screens/chat.dart';
import 'package:frontend/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índice da tela selecionada

  // Lista de telas que serão exibidas ao trocar de índice
  final List<Widget> _pages = [
    const HomePage(),
    const ConsumptionPage(),
    const GenerationPage(),
    const AlertsPage(),
    const ChatPage(),
  ];

  // Método para trocar de tela quando um item é selecionado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Mostra a tela correspondente ao índice

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Mantém os ícones visíveis
        backgroundColor: Colors.purple, // Cor de fundo da barra
        selectedItemColor: Colors.white, // Cor do item selecionado
        unselectedItemColor: Colors.white70, // Cor dos itens não selecionados
        currentIndex: _selectedIndex, // Índice da tela atual
        onTap: _onItemTapped, // Função ao clicar nos itens
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Consumo'),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_exploration),
            label: 'Geração',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}

class ConsumptionPage extends StatelessWidget {
  const ConsumptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Página de Consumo', style: TextStyle(fontSize: 24)),
    );
  }
}

class GenerationPage extends StatelessWidget {
  const GenerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Mais Opções', style: TextStyle(fontSize: 24)),
    );
  }
}
