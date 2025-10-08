import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RecarregarPage extends StatefulWidget {
  final Function(double, String, String) onRecarga;

  RecarregarPage({required this.onRecarga});

  @override
  _RecarregarPageState createState() => _RecarregarPageState();
}

class _RecarregarPageState extends State<RecarregarPage> {
  final ApiService api = ApiService(); // instância da API

  double? valorSelecionado;
  String metodoSelecionado = "Emola"; // carteira móvel ou Simo Rede
  String bancoSimoSelecionado = "BIM";

  final TextEditingController valorController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  // Campos do cartão Simo Rede
  final TextEditingController cartaoController = TextEditingController();
  final TextEditingController validadeController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController titularController = TextEditingController();

  final List<double> valores = [100, 200, 500, 1000];
  final List<String> metodos = ["Emola", "M-Pesa", "Ponto 24", "MKesh", "Simo Rede"];
  final List<String> bancosSimo = ["BIM", "BCI", "Moza", "Standard"];

  void confirmarPagamento() async {
    double? valor;
    if (valorController.text.isNotEmpty) {
      valor = double.tryParse(valorController.text);
    } else {
      valor = valorSelecionado;
    }

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Insira um valor válido superior a 0.")),
      );
      return;
    }

    try {
      // Diferenciar Simo Rede e carteiras móveis
      if (metodoSelecionado != "Simo Rede") {
        String numero = numeroController.text.trim();
        if (!_validarNumero(numero, metodoSelecionado)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Número inválido para $metodoSelecionado.")),
          );
          return;
        }

        // Chama a API de pagamento
        Map<String, dynamic> resultado = await api.recarregarSaldo(
          cartao: numero,
          valor: valor,
          metodo: metodoSelecionado,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['mensagem'] ?? 'Pagamento concluído')),
        );

        // Atualiza o saldo local se sucesso
        if (resultado['status'] == 'sucesso') {
          widget.onRecarga(valor, metodoSelecionado, numero);
          Navigator.pop(context);
        }

      } else {
        // Dados do cartão Simo Rede
        String cartao = cartaoController.text.trim();
        String validade = validadeController.text.trim();
        String cvv = cvvController.text.trim();
        String titular = titularController.text.trim();

        if (cartao.length != 16 ||
            validade.isEmpty ||
            cvv.length != 3 ||
            titular.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Preencha corretamente os dados do cartão.")),
          );
          return;
        }

        // Chama a API de pagamento para Simo Rede
        Map<String, dynamic> resultado = await api.recarregarSaldo(
          cartao: cartao,
          valor: valor,
          metodo: "Simo Rede - $bancoSimoSelecionado",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['mensagem'] ?? 'Pagamento concluído')),
        );

        if (resultado['status'] == 'sucesso') {
          widget.onRecarga(valor, "Simo Rede - $bancoSimoSelecionado", cartao);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }
  }

  bool _validarNumero(String numero, String metodo) {
    if (numero.length != 9) return false;

    switch (metodo) {
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Escolha ou digite o valor para recarregar:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Wrap(
                spacing: 15,
                runSpacing: 15,
                children: valores.map((valor) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        valorSelecionado = valor;
                        valorController.clear();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: valorSelecionado == valor
                          ? Colors.green[800]
                          : Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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

              TextField(
                controller: valorController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Ou digite outro valor",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (metodoSelecionado != "Simo Rede")
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

              DropdownButtonFormField<String>(
                value: metodoSelecionado,
                items: metodos.map((m) {
                  return DropdownMenuItem(
                    value: m,
                    child: Text(m),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    metodoSelecionado = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Selecione o método de pagamento",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Seleção do banco dentro do Simo Rede
              if (metodoSelecionado == "Simo Rede")
                DropdownButtonFormField<String>(
                  value: bancoSimoSelecionado,
                  items: bancosSimo.map((banco) {
                    return DropdownMenuItem(
                      value: banco,
                      child: Text(banco),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      bancoSimoSelecionado = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Selecione o banco",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              if (metodoSelecionado == "Simo Rede") ...[
                TextField(
                  controller: cartaoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Número do Cartão",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: validadeController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: "Validade (MM/AA)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "CVV",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titularController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Nome do titular",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

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
      ),
    );
  }
}
