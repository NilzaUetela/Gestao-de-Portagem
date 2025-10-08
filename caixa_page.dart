import 'package:flutter/material.dart';

class CaixaPage extends StatefulWidget {
  final String nomeCaixa;

  CaixaPage({required this.nomeCaixa});

  @override
  _CaixaPageState createState() => _CaixaPageState();
}

class _CaixaPageState extends State<CaixaPage> {
  String _mensagem = "Nenhuma operação ainda";

  // Tabela fictícia de valores
  final Map<String, double> categorias = {
    "Turismo": 50.0,
    "Atrelado": 100.0,
    "Transporte Público": 80.0,
    "Camião Pesado": 150.0,
  };

  void cobrar(String categoria, double valor) {
    setState(() {
      _mensagem = "Veículo $categoria pagou MZN $valor";
    });
  }

  void abrirCancela() {
    setState(() {
      _mensagem = "✅ Cancela Aberta";
    });
  }

  void fecharCancela() {
    setState(() {
      _mensagem = "❌ Cancela Fechada";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nomeCaixa)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Selecione a categoria do veículo:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Botões das categorias
            ...categorias.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () => cobrar(entry.key, entry.value),
                  child: Text("${entry.key} - MZN ${entry.value}"),
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            // Botão Abrir Cancela
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(15),
              ),
              onPressed: abrirCancela,
              child: Text("Abrir Cancela"),
            ),

            const SizedBox(height: 10),

            // Botão Fechar Cancela
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(15),
              ),
              onPressed: fecharCancela,
              child: Text("Fechar Cancela"),
            ),

            const SizedBox(height: 30),

            // Mensagem de operação
            Text(
              _mensagem,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
