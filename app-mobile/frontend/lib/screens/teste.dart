import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';

class PessoasScreen extends StatefulWidget {
  @override
  _PessoasScreenState createState() => _PessoasScreenState();
}

class _PessoasScreenState extends State<PessoasScreen> {
  late Future<List<dynamic>> pessoas;

  @override
  void initState() {
    super.initState();
    pessoas = ApiService.buscarPessoas(); // Chama a API ao iniciar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista de Pessoas")),
      body: FutureBuilder<List<dynamic>>(
        future: pessoas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Nenhuma pessoa encontrada."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var pessoa = snapshot.data![index];
                return ListTile(
                  title: Text(pessoa["nome"] ?? "Sem Nome"),
                  subtitle: Text("ID: ${pessoa["idPessoa"]}, endereço: ${pessoa['endereco']}"),
                );
              },
            );
          }
        },
      ),
    );
  }
}