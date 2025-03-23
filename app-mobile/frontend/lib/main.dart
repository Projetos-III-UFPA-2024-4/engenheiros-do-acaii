import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/navigation_provider.dart';
import 'package:frontend/screens/alert.dart';
import 'package:frontend/screens/chat.dart';
import 'package:frontend/screens/consumption.dart';
import 'package:frontend/screens/generation.dart';
import 'package:frontend/screens/home_page.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NavigationProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Define a rota inicial
      initialRoute: '/',
      // Mapeia as rotas nomeadas
      routes: {
        '/': (context) => const HomeScreen(), // Tela com BottomNavigationBar
        '/alerts': (context) => const AlertsPage(),
        '/chat': (context) => const ChatPage(),
        '/consumption': (context) => const ConsumptionPage(),
        '/generation': (context) => const GenerationPage(),
        '/homePage': (context) => const HomePage(),

      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Widget> _pages = [
    const HomePage(),
    const ConsumptionPage(),
    const GenerationPage(),
    const AlertsPage(),
    const ChatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      // Exibe a página correspondente ao índice selecionado
      body: _pages[navigationProvider.selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.purple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: navigationProvider.selectedIndex,
        onTap: (index) => navigationProvider.changePage(index),
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
