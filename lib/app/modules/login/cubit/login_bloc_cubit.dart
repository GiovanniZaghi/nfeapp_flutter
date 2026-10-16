import 'package:bloc/bloc.dart';
import '../../../repositories/login/login_repository.dart';
import 'login_bloc_state.dart';

class LoginBlocCubit extends Cubit<LoginBlocState> {
  final LoginRepository loginRepository;

  LoginBlocCubit({required this.loginRepository})
    : super(LoginBlocState.initial());

  Future<void> checkUrl(String cnpj) async {
    try {
      emit(state.copyWith(status: LoginStateStatus.loading));
      await loginRepository.checkUrl(cnpj);
      emit(state.copyWith(status: LoginStateStatus.initial));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LoginStateStatus.error,
          errorMessage: "Erro ao buscar host e porta: $e",
        ),
      );
    }
  }

  Future<void> login(String login, String password) async {
    try {
      emit(state.copyWith(status: LoginStateStatus.loading));
      final loginValidation = await loginRepository.login(login, password);

      if (loginValidation.validado == 'T' &&
          login.isNotEmpty &&
          password.isNotEmpty) {
        emit(state.copyWith(status: LoginStateStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStateStatus.error,
            errorMessage: 'Usuário ou senha incorretos',
          ),
        );
      }
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: LoginStateStatus.error,
          errorMessage: "Erro ao efetuar login: $e",
        ),
      );
    }
  }
}
