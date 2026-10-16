import 'package:equatable/equatable.dart';
import 'package:match/match.dart';
import '../../../../../repositories/product/model/consult_product_model.dart';

part 'consult_product_bloc_state.g.dart';

@match
enum ConsultProductStateStatus { initial, loading, error, success }

class ConsultProductBlocState extends Equatable {
  final List<ConsultProductModel>? products;
  final ConsultProductStateStatus status;
  final String? errorMessage;

  const ConsultProductBlocState({
    required this.products,
    required this.status,
    this.errorMessage,
  });

  ConsultProductBlocState.initial()
    : products = [],
      status = ConsultProductStateStatus.initial,
      errorMessage = null;

  @override
  List<Object?> get props => [products, status, errorMessage];

  ConsultProductBlocState copyWith({
    List<ConsultProductModel>? products,
    ConsultProductStateStatus? status,
    String? errorMessage,
  }) {
    return ConsultProductBlocState(
      products: products ?? this.products,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
