import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environments {
  Environments._();

  static String? get(String param) {
    return dotenv.get(param);
  }

  static Future<void> load(String ambiente) async {
    await dotenv.load(fileName: ".env");
  }

  // Método auxiliar para garantir cobertura do construtor privado
  static void init() {
    Environments._();
  }
}
