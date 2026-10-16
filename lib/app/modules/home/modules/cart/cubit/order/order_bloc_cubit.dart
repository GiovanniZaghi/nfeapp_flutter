import 'package:bloc/bloc.dart';
import 'package:nfeapp_flutter/app/repositories/order/order_repository.dart';
import 'order_bloc_state.dart';

class OrderBlocCubit extends Cubit<OrderBlocState> {
  final OrderRepository orderRepository;
  OrderBlocCubit({required this.orderRepository})
    : super(OrderBlocState.initial());

  Future<void> checkUrl() async {
    try {
      emit(state.copyWith(status: OrderStateStatus.loading));
      final products = await orderRepository.getProducts();

      print("Oq temos aq ${products.toString()}");

      emit(
        state.copyWith(
          status: OrderStateStatus.success,
          productModel: products,
        ),
      );
    } on Exception {
      emit(
        state.copyWith(
          status: OrderStateStatus.error,
          errorMessage: "Erro ao efetuar Login",
        ),
      );
    }
  }

  Future<void> fetchOrders() async {
    try {
      emit(state.copyWith(status: OrderStateStatus.loading));

      final orders = await orderRepository.getOrders();
      print("Pedidos carregados: ${orders.toString()}");

      emit(
        state.copyWith(status: OrderStateStatus.success, orderModel: orders),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OrderStateStatus.error,
          errorMessage: "Erro ao buscar pedidos",
        ),
      );
    }
  }

  Future<void> getOrders({String implemented = "NAO"}) async {
    try {
      emit(state.copyWith(status: OrderStateStatus.loading));

      final orders = await orderRepository.getOrders(implemented: implemented);

      emit(
        state.copyWith(status: OrderStateStatus.success, orderModel: orders),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OrderStateStatus.error,
          errorMessage: "Erro ao carregar pedidos",
        ),
      );
    }
  }
}
