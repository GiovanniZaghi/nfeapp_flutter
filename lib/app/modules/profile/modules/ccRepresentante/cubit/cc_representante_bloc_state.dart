import 'package:equatable/equatable.dart';
import '../../../../../repositories/ccRepresentante/model/cc_representante_model.dart';

enum CCRepresentanteStatus { initial, loading, success, error }

class CCRepresentanteState extends Equatable {
  final List<CCRepresentanteModel> extrato;
  final CCRepresentanteStatus status;
  final String? errorMessage;

  const CCRepresentanteState({
    required this.extrato,
    required this.status,
    this.errorMessage,
  });

  CCRepresentanteState.initial()
    : extrato = const [],
      status = CCRepresentanteStatus.initial,
      errorMessage = null;

  @override
  List<Object?> get props => [extrato, status, errorMessage];

  CCRepresentanteState copyWith({
    List<CCRepresentanteModel>? extrato,
    CCRepresentanteStatus? status,
    String? errorMessage,
  }) {
    return CCRepresentanteState(
      extrato: extrato ?? this.extrato,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
