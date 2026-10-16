import 'package:equatable/equatable.dart';
import '../../../../../../repositories/customer/model/customer_model.dart';
import '../../../../../../repositories/payment/model/payment_model.dart';
import '../../../../../../repositories/product/model/consult_product_model.dart';
import '../../../../../../repositories/finishCard/model/cart_model.dart';
import '../../../../../../repositories/finishCard/model/cart_order_model.dart';

part 'finish_bloc_state.g.dart';

enum FinishCartStatus { initial, loading, error, success }

class FinishCartState extends Equatable {
  final List<ConsultProductModel> produtos;
  final CustomerModel? cliente;
  final CondicaoPagamentoModel? condicaoPagamento;
  final TipoPagamentoModel? tipoPagamento;
  final String obs;
  final String vendedorLogin;
  final String empresaId;
  final double total;
  final FinishCartStatus status;
  final String? errorMessage;
  final String? successMessage;

  final CartModel? pedidoEmEdicao;
  final List<CartOrderModel> produtosPedido;

  const FinishCartState({
    required this.produtos,
    this.cliente,
    this.condicaoPagamento,
    this.tipoPagamento,
    this.obs = '',
    this.vendedorLogin = '',
    this.empresaId = '',
    this.total = 0.0,
    this.status = FinishCartStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.pedidoEmEdicao,
    this.produtosPedido = const [],
  });

  factory FinishCartState.initial() {
    return const FinishCartState(produtos: []);
  }

  FinishCartState copyWith({
    List<ConsultProductModel>? produtos,
    CustomerModel? cliente,
    CondicaoPagamentoModel? condicaoPagamento,
    TipoPagamentoModel? tipoPagamento,
    String? obs,
    String? vendedorLogin,
    String? empresaId,
    double? total,
    FinishCartStatus? status,
    String? errorMessage,
    String? successMessage,
    CartModel? pedidoEmEdicao,
    List<CartOrderModel>? produtosPedido,
  }) {
    return FinishCartState(
      produtos: produtos ?? this.produtos,
      cliente: cliente ?? this.cliente,
      condicaoPagamento: condicaoPagamento ?? this.condicaoPagamento,
      tipoPagamento: tipoPagamento ?? this.tipoPagamento,
      obs: obs ?? this.obs,
      vendedorLogin: vendedorLogin ?? this.vendedorLogin,
      empresaId: empresaId ?? this.empresaId,
      total: total ?? _calculaTotal(produtos ?? this.produtos),
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      pedidoEmEdicao: pedidoEmEdicao ?? this.pedidoEmEdicao,
      produtosPedido: produtosPedido ?? this.produtosPedido,
    );
  }

  double _calculaTotal(List<ConsultProductModel> produtos) {
    return produtos.fold<double>(
      0.0,
      (sum, p) =>
          sum +
          (double.tryParse(p.preco.replaceAll(',', '.')) ?? 0) * p.quantidade,
    );
  }

  @override
  List<Object?> get props => [
    produtos,
    cliente,
    condicaoPagamento,
    tipoPagamento,
    obs,
    vendedorLogin,
    empresaId,
    total,
    status,
    errorMessage,
    successMessage,
    pedidoEmEdicao,
    produtosPedido,
  ];
}
