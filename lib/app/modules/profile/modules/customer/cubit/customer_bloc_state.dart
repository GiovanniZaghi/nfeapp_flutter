import 'package:equatable/equatable.dart';
import 'package:match/match.dart';
import '../../../../../repositories/customer/model/customer_model.dart';

part 'customer_bloc_state.g.dart';

@match
enum CustomerStateStatus { initial, loading, error, success }

class CustomerBlocState extends Equatable {
  final List<CustomerModel>? customers;
  final CustomerStateStatus status;
  final String? errorMessage;
  final String? successMessage;

  const CustomerBlocState({
    required this.customers,
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  CustomerBlocState.initial()
    : status = CustomerStateStatus.initial,
      customers = [],
      errorMessage = null,
      successMessage = null;

  @override
  List<Object?> get props => [customers, status, errorMessage, successMessage];

  CustomerBlocState copyWith({
    List<CustomerModel>? customers,
    CustomerStateStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return CustomerBlocState(
      customers: customers ?? this.customers,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
