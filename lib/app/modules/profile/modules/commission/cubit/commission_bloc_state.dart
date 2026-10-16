import 'package:equatable/equatable.dart';
import 'package:match/match.dart';
import '../../../../../repositories/commission/model/commission_model.dart';

part 'commission_bloc_state.g.dart';

@match
enum CommissionBlocStatus { initial, loading, success, error }

class CommissionState extends Equatable {
  final List<CommissionModel> commissions;
  final CommissionBlocStatus status;
  final String? errorMessage;

  const CommissionState({
    required this.commissions,
    required this.status,
    this.errorMessage,
  });

  CommissionState.initial()
    : commissions = const [],
      status = CommissionBlocStatus.initial,
      errorMessage = null;

  @override
  List<Object?> get props => [commissions, status, errorMessage];

  CommissionState copyWith({
    List<CommissionModel>? commissions,
    CommissionBlocStatus? status,
    String? errorMessage,
  }) {
    return CommissionState(
      commissions: commissions ?? this.commissions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
