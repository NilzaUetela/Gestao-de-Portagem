import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> usuarios = [];

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _biController = TextEditingController();
  final TextEditingController _moradaController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  final TextEditingController _cartaoController = TextEditingController();
  final TextEditingController _saldoController = TextEditingController();

  final TextEditingController _numeroCartaoController = TextEditingController();
  final TextEditingController _valorRecarregarController = TextEditingController();
  String _carteiraSelecionada = "Emola";

  Map<String, dynamic>? usuarioSelecionado;

  // Relatórios recebidos dos caixas
  List<Map<String, dynamic>> relatorios = [];

  String filtroRelatorio = "Diário";
  final List<String> periodos = ["Diário", "Semanal", "Mensal"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _adicionarUsuario() {
    if (_nomeController.text.isNotEmpty && _cartaoController.text.isNotEmpty) {
      setState(() {
        usuarios.add({
          "nome": _nomeController.text,
          "bi": _biController.text,
          "morada": _moradaController.text,
          "matricula": _matriculaController.text,
          "modelo": _modeloController.text,
          "email": _emailController.text,
          "contacto": _contactoController.text,
          "cartao": _cartaoController.text,
          "saldo": double.tryParse(_saldoController.text) ?? 0.0,
        });
      });
      _nomeController.clear();
      _biController.clear();
      _moradaController.clear();
      _matriculaController.clear();
      _modeloController.clear();
      _emailController.clear();
      _contactoController.clear();
      _cartaoController.clear();
      _saldoController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuário adicionado com sucesso!")),
      );
    }
  }

  void _buscarUsuario() {
    String numeroCartao = _numeroCartaoController.text;
    setState(() {
      usuarioSelecionado = usuarios.firstWhere(
        (u) => u["cartao"] == numeroCartao,
        orElse: () => {},
      );
    });
  }

  void _recarregarSaldo() {
    if (usuarioSelecionado != null && _valorRecarregarController.text.isNotEmpty) {
      double valor = double.tryParse(_valorRecarregarController.text) ?? 0.0;
      if (valor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("O valor deve ser maior que 0!")),
        );
        return;
      }
      setState(() {
        usuarioSelecionado!["saldo"] += valor;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saldo recarregado via $_carteiraSelecionada: MZN $valor")),
      );
      _valorRecarregarController.clear();
    }
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green,
            child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
          ),
          SizedBox(width: 12),
          Text(
            "Administrador",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[900]),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        keyboardType: type ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildRelatorios() {
    List<Map<String, dynamic>> relatoriosFiltrados = relatorios; // Aqui depois você aplica filtro real

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: DropdownButton<String>(
            value: filtroRelatorio,
            items: periodos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) {
              setState(() {
                filtroRelatorio = v!;
              });
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(color: Colors.grey),
              columns: const [
                DataColumn(label: Text("Caixa")),
                DataColumn(label: Text("Classe")),
                DataColumn(label: Text("Qtd Veículos")),
                DataColumn(label: Text("Valor Total")),
              ],
              rows: relatoriosFiltrados.map((r) {
                return DataRow(cells: [
                  DataCell(Text(r["caixa"])),
                  DataCell(Text(r["classe"].toString())),
                  DataCell(Text(r["qtd"].toString())),
                  DataCell(Text("MZN ${r["valor"].toStringAsFixed(2)}")),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Administração"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: "Visualizar"),
            Tab(text: "Adicionar"),
            Tab(text: "Recarregar"),
            Tab(text: "Relatórios"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Visualizar
          _buildVisualizar(),
          // Adicionar
          _buildAdicionar(),
          // Recarregar
          _buildRecarregar(),
          // Relatórios
          _buildRelatorios(),
        ],
      ),
    );
  }

  Widget _buildVisualizar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAdminHeader(),
          _buildTextField(_numeroCartaoController, "Número do Cartão"),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _buscarUsuario,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text("Buscar Usuário"),
          ),
          SizedBox(height: 20),
          if (usuarioSelecionado != null && usuarioSelecionado!.isNotEmpty)
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Text("Nome: ${usuarioSelecionado!['nome']}"),
                      Text("BI: ${usuarioSelecionado!['bi']}"),
                      Text("Morada: ${usuarioSelecionado!['morada']}"),
                      Text("Matrícula: ${usuarioSelecionado!['matricula']}"),
                      Text("Modelo: ${usuarioSelecionado!['modelo']}"),
                      Text("Email: ${usuarioSelecionado!['email']}"),
                      Text("Contacto: ${usuarioSelecionado!['contacto']}"),
                      Text("Saldo: MZN ${usuarioSelecionado!['saldo']}"),
                    ],
                  ),
                ),
              ),
            )
          else
            Text("Nenhum usuário encontrado."),
        ],
      ),
    );
  }

  Widget _buildAdicionar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildAdminHeader(),
          _buildTextField(_nomeController, "Nome Completo"),
          _buildTextField(_biController, "Bilhete de Identidade"),
          _buildTextField(_moradaController, "Morada"),
          _buildTextField(_matriculaController, "Matrícula do Carro"),
          _buildTextField(_modeloController, "Modelo do Carro"),
          _buildTextField(_emailController, "Email"),
          _buildTextField(_contactoController, "Contacto"),
          _buildTextField(_cartaoController, "Número do Cartão"),
          _buildTextField(_saldoController, "Saldo Inicial", type: TextInputType.number),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _adicionarUsuario,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text("Adicionar Usuário"),
          ),
        ],
      ),
    );
  }

  Widget _buildRecarregar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildAdminHeader(),
          _buildTextField(_numeroCartaoController, "Número do Cartão"),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _buscarUsuario,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text("Buscar Usuário"),
          ),
          SizedBox(height: 20),
          if (usuarioSelecionado != null && usuarioSelecionado!.isNotEmpty) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.green[50],
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nome: ${usuarioSelecionado!['nome']}", style: TextStyle(fontSize: 16)),
                    Text("Saldo Atual: MZN ${usuarioSelecionado!['saldo']}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _carteiraSelecionada,
                      decoration: InputDecoration(
                        labelText: "Carteira Móvel",
                        filled: true,
                        fillColor: Colors.green[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ["Emola", "M-Pesa", "Ponto 24"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (value) => setState(() => _carteiraSelecionada = value!),
                    ),
                    SizedBox(height: 12),
                    _buildTextField(_valorRecarregarController, "Valor a recarregar", type: TextInputType.number),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _recarregarSaldo,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                      child: Center(child: Text("Recarregar")),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Text("Nenhum usuário selecionado."),
        ],
      ),
    );
  }
}
