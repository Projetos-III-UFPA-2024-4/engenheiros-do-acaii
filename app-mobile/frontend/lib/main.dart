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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/alerts': (context) => const AlertsPage(),
        '/chat': (context) => const ChatPage(),
        '/consumption': (context) => ConsumptionPage(),
        '/generation': (context) => const GenerationPage(),
        '/homePage': (context) => const HomePage(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Widget> _pages = [
    HomePage(),
    ConsumptionPage(),
    GenerationPage(),
    const RefreshableWrapper(child: AlertsPage()),
    const RefreshableWrapper(child: ChatPage()),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
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

class RefreshableWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  
  const RefreshableWrapper({
    super.key,
    required this.child,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.purple, // Cor do indicador de refresh
      backgroundColor: Colors.white, // Cor de fundo
      displacement: 40.0, // Posição do indicador
      edgeOffset: 0, // Começa desde o topo
      onRefresh: onRefresh ?? () async {
        // Lógica padrão caso não seja fornecido um onRefresh específico
        await Future.delayed(const Duration(seconds: 1));
        
        // Se a página for Stateful e tiver um método refresh, chame:
        // if (child is RefreshablePage) {
        //   await (child as RefreshablePage).refreshData();
        // }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: child,
        ),
      ),
    );
  }
}