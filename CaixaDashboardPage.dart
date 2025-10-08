import 'package:flutter/material.dart';

class CaixaDashboardPage extends StatefulWidget {
  final Map<String, dynamic> caixa;

  CaixaDashboardPage({required this.caixa});

  @override
  _CaixaDashboardPageState createState() => _CaixaDashboardPageState();
}

class _CaixaDashboardPageState extends State<CaixaDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> veiculosPorClasse = {
    "Classe 1": 0,
    "Classe 2": 0,
    "Classe 3": 0,
    "Classe 4": 0,
  };
  Map<String, double> valoresPorClasse = {
    "Classe 1": 50.0,
    "Classe 2": 80.0,
    "Classe 3": 120.0,
    "Classe 4": 150.0,
  };
  List<Map<String, dynamic>> historico = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void cobrar(String classe, {bool desconto = false}) {
    double valor = valoresPorClasse[classe]!;
    if (desconto) valor *= 0.8; // 20% de desconto

    setState(() {
      veiculosPorClasse[classe] = veiculosPorClasse[classe]! + 1;
      historico.insert(0, {
        "classe": classe,
        "valor": valor,
        "data": DateTime.now().toString(),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Cobrança realizada: $classe - MZN ${valor.toStringAsFixed(2)}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel do ${widget.caixa["nome"]}"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Cobrança"),
            Tab(text: "Histórico"),
            Tab(text: "Relatório"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCobrancaTab(),
          _buildHistoricoTab(),
          _buildRelatorioTab(),
        ],
      ),
    );
  }

  Widget _buildCobrancaTab() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: valoresPorClasse.keys.map((classe) {
        return Card(
          child: ListTile(
            title: Text("$classe - MZN ${valoresPorClasse[classe]}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.attach_money, color: Colors.green),
                  onPressed: () => cobrar(classe),
                ),
                IconButton(
                  icon: Icon(Icons.discount, color: Colors.orange),
                  onPressed: () => cobrar(classe, desconto: true),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoricoTab() {
    return ListView.builder(
      itemCount: historico.length,
      itemBuilder: (context, index) {
        final item = historico[index];
        return ListTile(
          title: Text("${item["classe"]} - MZN ${item["valor"]}"),
          subtitle: Text(item["data"]),
        );
      },
    );
  }

  Widget _buildRelatorioTab() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: veiculosPorClasse.keys.map((classe) {
        final qtd = veiculosPorClasse[classe]!;
        final total = qtd * valoresPorClasse[classe]!;
        return ListTile(
          title: Text("$classe"),
          subtitle: Text("Veículos: $qtd - Total: MZN ${total.toStringAsFixed(2)}"),
        );
      }).toList(),
    );
  }
}
