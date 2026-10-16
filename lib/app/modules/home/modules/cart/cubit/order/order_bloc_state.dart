import 'package:nfeapp_flutter/app/repositories/order/model/product_model.dart';
import 'package:nfeapp_flutter/app/repositories/order/model/order_model.dart';
import 'package:equatable/equatable.dart';
import 'package:match/match.dart';

part 'order_bloc_state.g.dart';

@match
enum OrderStateStatus { initial, loading, error, success }

class OrderBlocState extends Equatable {
  final List<ProductModel>? productModel;
  final List<OrderModel>? orderModel;
  final OrderStateStatus status;
  final String? errorMessage;
  final String? successMessage;

  const OrderBlocState({
    required this.productModel,
    required this.orderModel,
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  OrderBlocState.initial()
    : status = OrderStateStatus.initial,
      productModel = [ProductModel()],
      orderModel = [OrderModel()],
      errorMessage = null,
      successMessage = null;

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    successMessage,
    productModel,
    orderModel,
  ];

  OrderBlocState copyWith({
    List<ProductModel>? productModel,
    List<OrderModel>? orderModel,
    OrderStateStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return OrderBlocState(
      productModel: productModel ?? this.productModel,
      orderModel: orderModel ?? this.orderModel,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
