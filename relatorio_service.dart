class RelatorioService {
  static List<Map<String, dynamic>> relatorios = [];

  static void adicionarRelatorio(Map<String, dynamic> relatorio) {
    relatorios.add(relatorio);
  }

  static List<Map<String, dynamic>> getRelatorios() {
    return relatorios;
  }

  static void limparRelatorios() {
    relatorios.clear();
  }
}
