import 'dart:async';

class TabelaPrecoEvent {
  static final _controller = StreamController<int>.broadcast();

  static Stream<int> get stream => _controller.stream;

  static void change(int tabela) {
    _controller.add(tabela);
  }
}
