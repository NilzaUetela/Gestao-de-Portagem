import 'package:flutter/material.dart';

class RecarregarPage extends StatefulWidget {
  final Function(double, String, String) onRecarga;

  RecarregarPage({required this.onRecarga});

  @override
  _RecarregarPageState createState() => _RecarregarPageState();
}

class _RecarregarPageState extends State<RecarregarPage> {
  double? valorSelecionado;
  String carteiraSelecionada = "Emola";
  final TextEditingController valorController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  final List<double> valores = [100, 200, 500, 1000];
  final List<String> carteiras = ["Emola", "M-Pesa", "Ponto 24", "MKesh"];

  void confirmarPagamento() {
    double? valor;

    // Prioridade para o valor digitado, caso exista
    if (valorController.text.isNotEmpty) {
      valor = double.tryParse(valorController.text);
    } else {
      valor = valorSelecionado;
    }

    // Valida valor
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Insira um valor válido superior a 0.")),
      );
      return;
    }

    // Valida carteira
    if (carteiraSelecionada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione a carteira móvel.")),
      );
      return;
    }

    // Valida número de celular
    String numero = numeroController.text.trim();
    if (!_validarNumero(numero, carteiraSelecionada)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Número inválido para $carteiraSelecionada.")),
      );
      return;
    }

    // Chama callback do Dashboard
    widget.onRecarga(valor, carteiraSelecionada, numero);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "Pagamento de MZN $valor via $carteiraSelecionada realizado com sucesso!"),
      ),
    );

    Navigator.pop(context);
  }

  bool _validarNumero(String numero, String carteira) {
    // Deve ter 9 dígitos
    if (numero.length != 9) return false;

    // Valida prefixo de acordo com a carteira
    switch (carteira) {
      case "Emola":
        return numero.startsWith("86") || numero.startsWith("87");
      case "M-Pesa":
        return numero.startsWith("84") || numero.startsWith("85");
      case "Ponto 24":
        return numero.startsWith("82") || numero.startsWith("83");
      case "MKesh":
        return numero.startsWith("88") || numero.startsWith("89");
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recarregar"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Escolha ou digite o valor para recarregar:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            // Botões de valores pré-definidos
            Wrap(
              spacing: 15,
              runSpacing: 15,
              children: valores.map((valor) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      valorSelecionado = valor;
                      valorController.clear(); // limpa input se usar botão
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: valorSelecionado == valor
                        ? Colors.green[800]
                        : Colors.green,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("MZN $valor",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Campo de valor manual
            TextField(
              controller: valorController,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: "Ou digite outro valor",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Campo número de celular
            TextField(
              controller: numeroController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Número de celular (+258)",
                hintText: "Ex: 861234567",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Seleção da carteira
            DropdownButtonFormField<String>(
              value: carteiraSelecionada,
              items: carteiras.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  carteiraSelecionada = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Selecione a carteira móvel",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: confirmarPagamento,
              icon: Icon(Icons.check_circle, color: Colors.white),
              label: Text("Confirmar Pagamento",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
