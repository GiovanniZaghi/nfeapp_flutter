import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../repositories/product/i_consult_product_repository.dart';
import '../../../../../repositories/product/model/consult_product_model.dart';
import 'consult_product_bloc_state.dart';

class ConsultProductBlocCubit extends Cubit<ConsultProductBlocState> {
  final IConsultProductRepository productRepository;

  ConsultProductBlocCubit({required this.productRepository})
    : super(ConsultProductBlocState.initial());

  IConsultProductRepository get repository => productRepository;

  Future<void> fetchProducts([int? tabela, String? tabelaTexto]) async {
    try {
      emit(state.copyWith(status: ConsultProductStateStatus.loading));

      final data = await productRepository.getProducts(tabela, tabelaTexto);

      emit(
        state.copyWith(
          status: ConsultProductStateStatus.success,
          products: data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ConsultProductStateStatus.error,
          errorMessage: 'Erro ao carregar produtos',
        ),
      );
    }
  }
}

Future<void> showPriceInfoDialog(
  BuildContext context,
  ConsultProductModel product,
) async {
  final bloc = context.read<ConsultProductBlocCubit>();

  final price = await bloc.repository.getProductPrices(product.codigo);

  if (price == null) {
    return showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Informações de preço"),
            content: const Text(
              "Não foi possível obter os preços deste produto.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok"),
              ),
            ],
          ),
    );
  }

  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Informações de preço"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Preço à vista: R\$ ${price.precoAvista}"),
              Text("Preço promocional: R\$ ${price.precoPromo}"),
              Text("Preço faturado: R\$ ${price.precoFaturado}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Ok"),
            ),
          ],
        ),
  );
}
