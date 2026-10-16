import 'model/payment_model.dart';

abstract class IPaymentRepository {
  Future<List<CondicaoPagamentoModel>> getCondicoesPagamento();
  Future<List<TipoPagamentoModel>> getTiposPagamento();
}
