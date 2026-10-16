import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../repositories/commission/i_commission_repository.dart';
import 'commission_bloc_state.dart';

class CommissionBlocCubit extends Cubit<CommissionState> {
  final ICommissionRepository repository;

  CommissionBlocCubit({required this.repository})
    : super(CommissionState.initial());

  Future<void> fetchCommissions({
    required String startDate,
    required String endDate,
  }) async {
    try {
      emit(state.copyWith(status: CommissionBlocStatus.loading));

      final prefs = await SharedPreferences.getInstance();
      final clientId = prefs.getString('userCodigo') ?? '';

      if (clientId.isEmpty) {
        emit(
          state.copyWith(
            status: CommissionBlocStatus.error,
            errorMessage: 'Código do cliente não encontrado',
          ),
        );
        return;
      }

      final commissions = await repository.getCommissions(
        clientId: clientId,
        startDate: startDate,
        endDate: endDate,
      );

      emit(
        state.copyWith(
          status: CommissionBlocStatus.success,
          commissions: commissions,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CommissionBlocStatus.error,
          errorMessage: 'Erro ao carregar comissões',
        ),
      );
    }
  }
}
