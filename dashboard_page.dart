import 'package:flutter/material.dart';
import 'recarregar_page.dart';
import 'historico_page.dart';
import 'package:intl/intl.dart'; // para formatar a data/hora

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  DashboardPage({required this.usuario});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late double saldo;
  List<Map<String, dynamic>> historico = [];

  @override
  void initState() {
    super.initState();
    saldo = widget.usuario["saldo"];
  }

  // Corrigido para aceitar 3 parâmetros
  void atualizarSaldo(double valor, String carteira, String numero) {
    setState(() {
      saldo += valor;
      historico.insert(0, {
        "tipo": "recarga",
        "descricao": "Recarga via $carteira (nº: $numero)",
        "valor": valor.toStringAsFixed(2),
        "data": DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Recarga de MZN $valor via $carteira realizada com sucesso!"),
      ),
    );
  }

  void usarPortagem(double valor) {
    if (saldo >= valor) {
      setState(() {
        saldo -= valor;
        historico.insert(0, {
          "tipo": "portagem",
          "descricao": "Uso da portagem",
          "valor": valor.toStringAsFixed(2),
          "data": DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now()),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Portagem paga: MZN $valor")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saldo insuficiente para usar a portagem.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Área do Usuário"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green[200],
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              widget.usuario["nome"],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Cartão Nº ${widget.usuario["cartao"]}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    infoItem("Email", widget.usuario["email"]),
                    infoItem("Saldo disponível", "${saldo.toStringAsFixed(2)} MT"),
                    infoItem("Contacto", widget.usuario["contacto"] ?? "N/D"),
                    infoItem("Matrícula", widget.usuario["matricula"] ?? "N/D"),
                    infoItem("Modelo do Carro", widget.usuario["modelo"] ?? "N/D"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 15,
              runSpacing: 15,
              alignment: WrapAlignment.center,
              children: [
                actionButton("Recarregar", Icons.account_balance_wallet, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecarregarPage(onRecarga: atualizarSaldo),
                    ),
                  );
                }),
                actionButton("Histórico", Icons.history, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoricoPage(historico: historico),
                    ),
                  );
                }),
                actionButton("Usar Portagem", Icons.directions_car, () {
                  usarPortagem(100); // valor fixo (ex: 100 MT)
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget infoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Text(valor,
              style: TextStyle(fontSize: 16, color: Colors.green[700])),
        ],
      ),
    );
  }

  Widget actionButton(String texto, IconData icone, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icone, size: 18, color: Colors.white),
      label: Text(texto, style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
