import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _cartaoController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();

  // Simulando base de dados
  List<Map<String, dynamic>> usuarios = [
    {
      "cartao": "1111",
      "nome": "Administrador",
      "email": "admin@app.com",
      "saldo": 0.0,
      "tipo": "admin"
    },
    {
      "cartao": "2222",
      "nome": "Nilza Wetela",
      "email": "nilza@gmail.com",
      "saldo": 500.0,
      "tipo": "user"
    },
  ];

  void _fazerLogin() {
    String numeroCartao = _cartaoController.text.trim();
    String nome = _nomeController.text.trim();

    var usuario = usuarios.firstWhere(
      (u) => u["cartao"] == numeroCartao && u["nome"] == nome,
      orElse: () => {},
    );

    if (usuario.isNotEmpty) {
      if (usuario["tipo"] == "admin") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(usuario: usuario),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Dados incorretos! Verifique cartão e nome.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título principal
              Text(
                "Gestão de Portagem",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 40),

              // Campo Número do Cartão
              TextField(
                controller: _cartaoController,
                decoration: InputDecoration(
                  labelText: "Número do Cartão",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Campo Nome Completo
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: "Nome Completo",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Botão Entrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _fazerLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Entrar",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Rodapé
              Text(
                "© 2025 Gestão de portagem. Desenvolvido por Mutare-Solutions",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
