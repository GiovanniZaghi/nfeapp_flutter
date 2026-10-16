import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/database/dao/cart/cart_dao.dart';
import '../../../../../../core/database/dao/cart/product_dao.dart';
import '../../../../../../repositories/customer/customer_repository.dart';
import '../../../../../../repositories/customer/model/customer_model.dart';
import '../../../../../../repositories/finishCard/finish_cart_repository.dart';
import '../../../../../../repositories/finishCard/model/cart_model.dart';
import '../../../../../../repositories/finishCard/model/cart_order_model.dart';
import '../../../../../../repositories/payment/model/payment_model.dart';
import '../../../../../../repositories/payment/payment_repository.dart';
import '../../../../../../repositories/product/model/consult_product_model.dart';
import 'finish_bloc_state.dart';

class FinishCartCubit extends Cubit<FinishCartState> {
  final PaymentRepository paymentRepository;
  final SharedPreferences prefs;
  final CustomerRepository customerRepository;
  final FinishCartRepository finishCartRepository;
  final CartDao _cartDao = CartDao();

  List<CustomerModel> clientesLista = [];
  List<ConsultProductModel> produtosLista = [];
  List<CondicaoPagamentoModel> condicoesPagamento = [];
  List<TipoPagamentoModel> tiposPagamento = [];

  FinishCartCubit({
    required this.paymentRepository,
    required this.prefs,
    required this.customerRepository,
    required this.finishCartRepository,
  }) : super(
         FinishCartState.initial().copyWith(
           // Todo endpoint que precisa do representante (GravaPed1/GravaPed2,
           // pesquisaCliente, RetornaCondPagto) usa o ID_REPR, não o CODIGO do login.
           vendedorLogin: prefs.getString('repId') ?? '',
           empresaId: prefs.getString('companyCodigo') ?? '',
         ),
       );

  void setCliente(CustomerModel cliente) =>
      emit(state.copyWith(cliente: cliente));

  void setCondicaoPagamento(CondicaoPagamentoModel pagamento) =>
      emit(state.copyWith(condicaoPagamento: pagamento));

  void setTipoPagamento(TipoPagamentoModel pagamento) =>
      emit(state.copyWith(tipoPagamento: pagamento));

  void setObservacao(String obs) => emit(state.copyWith(obs: obs));

  void setProdutos(List<ConsultProductModel> itens) =>
      emit(state.copyWith(produtos: _agruparProdutos(itens)));

  void setProdutosDoPedido(List<CartOrderModel> produtos) =>
      emit(state.copyWith(produtosPedido: produtos));

  void setPedidoEmEdicao(CartModel pedido) =>
      emit(state.copyWith(pedidoEmEdicao: pedido));

  void addProduto(ConsultProductModel produto) {
    final novaLista = List<ConsultProductModel>.from(state.produtos);
    final index = novaLista.indexWhere((p) => p.codigo == produto.codigo);

    if (index >= 0) {
      novaLista[index].quantidade += produto.quantidadePositiva;
    } else {
      novaLista.add(produto.copiaComQuantidadePositiva);
    }

    emit(state.copyWith(produtos: _agruparProdutos(novaLista)));
  }

  void resetarCampos() {
    emit(
      FinishCartState.initial().copyWith(
        vendedorLogin: state.vendedorLogin,
        empresaId: state.empresaId,
      ),
    );
  }

  void limparMensagens() {
    emit(
      state.copyWith(
        successMessage: '',
        errorMessage: '',
        status: FinishCartStatus.initial,
      ),
    );
  }

  Future<void> fetchProdutosLocais() async {
    try {
      final dao = ConsultProductDao();
      produtosLista = await dao.getProducts();
    } catch (e) {
      produtosLista = [];
      emit(
        state.copyWith(
          status: FinishCartStatus.error,
          errorMessage: "Erro ao buscar produtos locais: $e",
        ),
      );
    }
  }

  Future<List<CustomerModel>> fetchClientes() async {
    try {
      final clientes = await customerRepository.getCustomers();
      clientesLista = clientes;
      return clientes;
    } catch (e) {
      final clientesOffline = await customerRepository.dao.getCustomers();
      clientesLista = clientesOffline;
      return clientesOffline;
    }
  }

  Future<List<CondicaoPagamentoModel>> fetchCondicoesPagamento() async {
    try {
      final condicoes = await paymentRepository.getCondicoesPagamento();
      condicoesPagamento = condicoes;
      return condicoes;
    } catch (e) {
      final condicoesOffline =
          await paymentRepository.dao.getCondicoesPagamento();
      condicoesPagamento = condicoesOffline;
      return condicoesOffline;
    }
  }

  Future<List<TipoPagamentoModel>> fetchTiposPagamento() async {
    try {
      final tipos = await paymentRepository.getTiposPagamento();
      tiposPagamento = tipos;
      return tipos;
    } catch (e) {
      final tiposOffline = await paymentRepository.dao.getTiposPagamento();
      tiposPagamento = tiposOffline;
      return tiposOffline;
    }
  }

  Future<List<CartModel>> fetchPedidosPendentes() async {
    try {
      return await _cartDao.getCarts();
    } catch (e) {
      emit(
        state.copyWith(
          status: FinishCartStatus.error,
          errorMessage: "Erro ao buscar pedidos: $e",
        ),
      );
      return [];
    }
  }

  Future<void> salvarPedidoLocal(CartModel pedido) async {
    try {
      await _cartDao.saveOrUpdateCart(pedido);
      emit(
        state.copyWith(
          status: FinishCartStatus.success,
          successMessage: "Pedido salvo com sucesso!",
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FinishCartStatus.error,
          errorMessage: "Erro ao salvar pedido: $e",
        ),
      );
    }
  }

  Future<void> atualizarPedidoLocal(CartModel pedidoAtualizado) async {
    await salvarPedidoLocal(pedidoAtualizado);
  }

  Future<void> excluirPedidoLocal(String numPed) async {
    try {
      await _cartDao.deleteCart(numPed);
      emit(
        state.copyWith(
          status: FinishCartStatus.success,
          successMessage: "Pedido excluído com sucesso!",
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FinishCartStatus.error,
          errorMessage: "Erro ao excluir pedido: $e",
        ),
      );
    }
  }

  Future<CartModel> montarPedidoComDesconto(
    double desconto, {
    String? tabela,
    String numPedCliente = '',
  }) async {
    final totalComDesconto = state.total - desconto;
    final agora = DateTime.now();

    final tabelaFinal =
        (tabela != null && tabela.trim().isNotEmpty)
            ? tabela.trim()
            : (prefs.getInt('tabelaPreco') ?? 2).toString();

    return CartModel(
      idEmpresa: state.empresaId,
      numPed: state.pedidoEmEdicao?.numPed ?? await _gerarNumeroPedido(),
      idVendedor: state.vendedorLogin,
      idCliente: state.cliente?.codigo ?? "",
      idTpPag: state.tipoPagamento?.codigo ?? "",
      idCondPag: state.condicaoPagamento?.codigo ?? "",
      valDesc: _formatarValor(desconto),
      obsPed: state.obs,
      totalPed: _formatarValor(totalComDesconto),
      dataPed:
          "${agora.day.toString().padLeft(2, '0')}/"
          "${agora.month.toString().padLeft(2, '0')}/${agora.year}",
      numPedCliente: numPedCliente.trim(),
      tabela: tabelaFinal,
      produtos: state.produtos.map(_converterProduto).toList(),
    );
  }

  Future<bool> enviarTodosPedidos() async {
    final pedidos = await fetchPedidosPendentes();
    if (pedidos.isEmpty) return false;

    bool todosEnviados = true;
    emit(state.copyWith(status: FinishCartStatus.loading));

    for (final pedido in pedidos) {
      final sucesso = await finishCartRepository.enviarPedido(pedido);
      if (!sucesso) {
        todosEnviados = false;
        break;
      } else {
        await _cartDao.deleteCart(pedido.numPed);
      }
    }

    emit(state.copyWith(status: FinishCartStatus.initial));
    return todosEnviados;
  }

  String _formatarValor(double valor) =>
      valor.toStringAsFixed(2).replaceAll('.', ',');

  Future<String> _gerarNumeroPedido() async {
    final pedidos = await _cartDao.getCarts();
    if (pedidos.isEmpty) return "1";

    final ultNum = pedidos
        .map((p) => int.tryParse(p.numPed) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return (ultNum + 1).toString();
  }

  Future<CartModel> montarPedido(double desconto) async {
    final totalComDesconto = state.total - desconto;
    final agora = DateTime.now();

    return CartModel(
      idEmpresa: state.empresaId,
      numPed: await _gerarNumeroPedido(),
      idVendedor: state.vendedorLogin,
      idCliente: state.cliente?.codigo ?? "",
      idTpPag: state.tipoPagamento?.codigo ?? "",
      idCondPag: state.condicaoPagamento?.codigo ?? "",
      valDesc: _formatarValor(desconto),
      obsPed: state.obs,
      totalPed: _formatarValor(totalComDesconto),
      dataPed:
          "${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year}",
      produtos: state.produtos.map(_converterProduto).toList(),
    );
  }

  CartOrderModel _converterProduto(ConsultProductModel p) {
    final precoDouble = double.tryParse(p.preco.replaceAll(',', '.')) ?? 0;
    return CartOrderModel(
      idProduto: p.codigo,
      quantidade: p.quantidade,
      preco: _formatarValor(precoDouble),
    );
  }

  List<ConsultProductModel> _agruparProdutos(
    List<ConsultProductModel> produtos,
  ) {
    final Map<String, ConsultProductModel> map = {};
    for (var p in produtos) {
      if (map.containsKey(p.codigo)) {
        map[p.codigo]!.quantidade += p.quantidade;
      } else {
        map[p.codigo] = p.copiaComQuantidadePositiva;
      }
    }
    return map.values.toList();
  }
}

extension ProdutoHelpers on ConsultProductModel {
  int get quantidadePositiva => quantidade > 0 ? quantidade : 1;

  ConsultProductModel get copiaComQuantidadePositiva => ConsultProductModel(
    codigo: codigo,
    produto: produto,
    preco: preco,
    estoque: estoque,
    imagem: imagem,
    quantidade: quantidadePositiva,
    obs: obs,
  );
}
