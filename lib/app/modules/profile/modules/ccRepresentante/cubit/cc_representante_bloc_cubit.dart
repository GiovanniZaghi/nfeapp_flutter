import 'package:bloc/bloc.dart';
import '../../../../../repositories/ccRepresentante/i_cc_representante_repository.dart';
import 'cc_representante_bloc_state.dart';

class CCRepresentanteBlocCubit extends Cubit<CCRepresentanteState> {
  final ICCRepresentanteRepository repository;

  CCRepresentanteBlocCubit({required this.repository})
    : super(CCRepresentanteState.initial());

  Future<void> fetchExtrato() async {
    try {
      emit(state.copyWith(status: CCRepresentanteStatus.loading));

      final extrato = await repository.getExtrato();

      emit(
        state.copyWith(status: CCRepresentanteStatus.success, extrato: extrato),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CCRepresentanteStatus.error,
          errorMessage: 'Erro ao carregar extrato',
        ),
      );
    }
  }
}
