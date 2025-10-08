import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CaixaDashboardPage extends StatefulWidget {
  final String nomeCaixa;

  CaixaDashboardPage({required this.nomeCaixa});

  @override
  _CaixaDashboardPageState createState() => _CaixaDashboardPageState();
}

class _CaixaDashboardPageState extends State<CaixaDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tarifas por classe
  Map<int, double> tarifas = {
    1: 50.0,
    2: 80.0,
    3: 120.0,
    4: 200.0,
    5: 300.0,
  };

  // Histórico de veículos pagos
  List<Map<String, dynamic>> historico = [];

  // Mensagem de status
  String _mensagem = "";

  // Filtro de relatório: "Hoje", "Semana", "Mês"
  String filtroRelatorio = "Hoje";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void cobrarVeiculo(int classe) {
    double valor = tarifas[classe]!;
    DateTime agora = DateTime.now();

    setState(() {
      historico.add({"classe": classe, "valor": valor, "data": agora});
      _mensagem = "Veículo da classe $classe cobrado: MZN ${valor.toStringAsFixed(2)}";
    });
  }

  void abrirCancela() {
    setState(() {
      _mensagem = "Cancela aberta!";
    });
  }

  void fecharCancela() {
    setState(() {
      _mensagem = "Cancela fechada!";
    });
  }

  // Aplica filtro de período no relatório
  List<Map<String, dynamic>> aplicarFiltro(String filtro) {
    DateTime agora = DateTime.now();
    DateTime inicio;

    if (filtro == "Hoje") {
      inicio = DateTime(agora.year, agora.month, agora.day);
    } else if (filtro == "Semana") {
      inicio = agora.subtract(Duration(days: agora.weekday - 1));
    } else if (filtro == "Mês") {
      inicio = DateTime(agora.year, agora.month, 1);
    } else {
      inicio = DateTime(2000); // padrão
    }

    return historico.where((v) => v["data"].isAfter(inicio)).toList();
  }

  // Formata data
  String formatarData(DateTime dt) {
    return DateFormat("dd/MM/yyyy HH:mm").format(dt);
  }

  // Constrói DataTable para relatório
  Widget buildRelatorioTabela(String filtro) {
    List<Map<String, dynamic>> listaFiltrada = aplicarFiltro(filtro);

    Map<int, int> contagem = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    Map<int, double> totalPorClasse = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var v in listaFiltrada) {
      int cl = v["classe"];
      double valor = v["valor"];
      contagem[cl] = contagem[cl]! + 1;
      totalPorClasse[cl] = totalPorClasse[cl]! + valor;
    }

    double totalGeral = totalPorClasse.values.fold(0, (a, b) => a + b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text("Classe")),
          DataColumn(label: Text("Veículos")),
          DataColumn(label: Text("Total MZN")),
        ],
        rows: contagem.keys.map((cl) {
          return DataRow(cells: [
            DataCell(Text(cl.toString())),
            DataCell(Text(contagem[cl].toString())),
            DataCell(Text(totalPorClasse[cl]!.toStringAsFixed(2))),
          ]);
        }).toList()
          ..add(DataRow(cells: [
            DataCell(Text("Total geral", style: TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text("-")),
            DataCell(Text(totalGeral.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
          ])),
      ),
    );
  }

  // Enviar relatório ao administrador (simulado)
  void enviarRelatorioAoAdmin() {
    // Aqui você poderia enviar via API ou salvar em service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Relatório enviado ao administrador com sucesso!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomeCaixa),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Cobrar"),
            Tab(text: "Histórico"),
            Tab(text: "Relatórios"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1️⃣ Aba Cobrar
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cobrar por classe de veículo:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: tarifas.keys.map((classe) {
                    return ElevatedButton(
                      onPressed: () => cobrarVeiculo(classe),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      ),
                      child: Text("Classe $classe - MZN ${tarifas[classe]!.toStringAsFixed(2)}"),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: abrirCancela,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                      child: Text("Abrir Cancela"),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: fecharCancela,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                      child: Text("Fechar Cancela"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(_mensagem, style: TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),

          // 2️⃣ Aba Histórico
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Histórico de veículos pagos:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: historico.length,
                    itemBuilder: (context, index) {
                      var t = historico[index];
                      return ListTile(
                        title: Text("Classe ${t["classe"]} – MZN ${t["valor"].toStringAsFixed(2)}"),
                        subtitle: Text("${formatarData(t["data"])}"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3️⃣ Aba Relatórios
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Relatório por período:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: filtroRelatorio,
                      items: ["Hoje", "Semana", "Mês"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filtroRelatorio = value!;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: enviarRelatorioAoAdmin,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: Text("Enviar ao Admin"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildRelatorioTabela(filtroRelatorio),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
