import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.188.134:3000"; // URL do seu mock server

  // Função existente para recarga de saldo
  Future<Map<String, dynamic>> recarregarSaldo({
    required String cartao,
    required double valor,
    required String metodo,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/recarregar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "cartao": cartao,
        "valor": valor,
        "metodo": metodo,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Falha ao recarregar saldo");
    }
  }

  // NOVO: função pagar para usar no RecarregarPage
  Future<String> pagar(String metodo, double valor) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/pagar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"metodo": metodo, "valor": valor}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["mensagem"] ?? "Pagamento realizado com sucesso!";
      } else {
        return "Falha ao processar pagamento (status: ${response.statusCode})";
      }
    } catch (e) {
      return "Erro ao processar pagamento: $e";
    }
  }
}
