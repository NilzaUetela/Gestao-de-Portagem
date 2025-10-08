import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_portagem.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        email TEXT,
        cartao TEXT UNIQUE,
        tipo TEXT,
        saldo REAL
      )
    ''');

    // Tabela de histórico de cobranças
    await db.execute('''
      CREATE TABLE historico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER,
        caixa TEXT,
        classe INTEGER,
        valor REAL,
        data TEXT,
        FOREIGN KEY(usuarioId) REFERENCES usuarios(id)
      )
    ''');
  }

  // ================== USUÁRIOS ==================
  Future<int> addUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    return await db.insert('usuarios', usuario, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUsuario(String cartao) async {
    final db = await database;
    var res = await db.query('usuarios', where: 'cartao = ?', whereArgs: [cartao]);
    if (res.isNotEmpty) return res.first;
    return null;
  }

  Future<List<Map<String, dynamic>>> getUsuariosPorTipo(String tipo) async {
    final db = await database;
    return await db.query('usuarios', where: 'tipo = ?', whereArgs: [tipo]);
  }

  Future<int> updateSaldo(String cartao, double novoSaldo) async {
    final db = await database;
    return await db.update(
      'usuarios',
      {'saldo': novoSaldo},
      where: 'cartao = ?',
      whereArgs: [cartao],
    );
  }

  // ================== HISTÓRICO ==================
  Future<int> addHistorico(Map<String, dynamic> historico) async {
    final db = await database;
    return await db.insert('historico', historico, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getHistoricoPorUsuario(int usuarioId) async {
    final db = await database;
    return await db.query(
      'historico',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'data DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getHistoricoPorCaixa(String caixa) async {
    final db = await database;
    return await db.query(
      'historico',
      where: 'caixa = ?',
      whereArgs: [caixa],
      orderBy: 'data DESC',
    );
  }

  // ================== RELATÓRIOS ==================
  Future<double> getTotalPorPeriodo(String caixa, DateTime inicio, DateTime fim) async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT SUM(valor) as total FROM historico
      WHERE caixa = ? AND data BETWEEN ? AND ?
    ''', [caixa, inicio.toIso8601String(), fim.toIso8601String()]);

    return res.first['total'] != null ? res.first['total'] as double : 0.0;
  }

  Future<Map<int, Map<String, dynamic>>> getResumoPorClasse(String caixa, DateTime inicio, DateTime fim) async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT classe, COUNT(*) as veiculos, SUM(valor) as total
      FROM historico
      WHERE caixa = ? AND data BETWEEN ? AND ?
      GROUP BY classe
    ''', [caixa, inicio.toIso8601String(), fim.toIso8601String()]);

    Map<int, Map<String, dynamic>> resumo = {};
    for (var row in res) {
      resumo[row['classe'] as int] = {
        "veiculos": row['veiculos'],
        "total": row['total']
      };
    }
    return resumo;
  }
}
