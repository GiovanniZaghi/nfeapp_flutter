import 'package:equatable/equatable.dart';
import 'package:match/match.dart';

part 'login_bloc_state.g.dart';

@match
enum LoginStateStatus { initial, loading, error, success, lucas, giovanni }

class LoginBlocState extends Equatable {
  //final ValidationModel? validationModel;
  //final List<UserAuthModel>? userAuthModel;
  final LoginStateStatus status;
  final String? errorMessage;
  final String? successMessage;

  const LoginBlocState({
    // required this.validationModel,
    //required this.userAuthModel,
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  LoginBlocState.initial()
    : status = LoginStateStatus.initial,
      errorMessage = null,
      successMessage = null;

  @override
  List<Object?> get props => [
    //validationModel,
    //userAuthModel,
    status,
    errorMessage,
    successMessage,
  ];

  LoginBlocState copyWith({
    //ValidationModel? validationModel,
    //List<UserAuthModel>? userAuthModel,
    LoginStateStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return LoginBlocState(
      //validationModel: validationModel ?? this.validationModel,
      //userAuthModel: userAuthModel ?? this.userAuthModel,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}
