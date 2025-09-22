import 'package:flutter/material.dart';

class HistoricoPage extends StatelessWidget {
  final List<Map<String, dynamic>> historico;

  HistoricoPage({required this.historico});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Histórico"),
        backgroundColor: Colors.green,
      ),
      body: historico.isEmpty
          ? Center(
              child: Text(
                "Nenhuma transação registrada.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final item = historico[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      item["tipo"] == "recarga"
                          ? Icons.account_balance_wallet
                          : Icons.directions_car,
                      color: item["tipo"] == "recarga"
                          ? Colors.green
                          : Colors.blue,
                    ),
                    title: Text(item["descricao"]),
                    subtitle: Text(item["data"]),
                    trailing: Text(
                      "MZN ${item["valor"]}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
