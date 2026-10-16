import 'package:bloc/bloc.dart';
import '../../../../../repositories/customer/i_customer_repository.dart';
import 'customer_bloc_state.dart';

class CustomerBlocCubit extends Cubit<CustomerBlocState> {
  final ICustomerRepository customerRepository;

  CustomerBlocCubit({required this.customerRepository})
    : super(CustomerBlocState.initial());

  Future<void> fetchCustomers() async {
    try {
      emit(state.copyWith(status: CustomerStateStatus.loading));

      final data = await customerRepository.getCustomers();

      emit(
        state.copyWith(status: CustomerStateStatus.success, customers: data),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CustomerStateStatus.error,
          errorMessage: 'Erro ao carregar clientes',
        ),
      );
    }
  }
}
