// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_bloc_state.dart';

// **************************************************************************
// MatchExtensionGenerator
// **************************************************************************

extension LoginStateStatusMatch on LoginStateStatus {
  T match<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function() error,
    required T Function() success,
    required T Function() lucas,
    required T Function() giovanni,
  }) {
    final v = this;
    if (v == LoginStateStatus.initial) {
      return initial();
    }

    if (v == LoginStateStatus.loading) {
      return loading();
    }

    if (v == LoginStateStatus.error) {
      return error();
    }

    if (v == LoginStateStatus.success) {
      return success();
    }

    if (v == LoginStateStatus.lucas) {
      return lucas();
    }

    if (v == LoginStateStatus.giovanni) {
      return giovanni();
    }

    throw Exception('LoginStateStatus.match failed, found no match for: $this');
  }

  T matchAny<T>({
    required T Function() any,
    T Function()? initial,
    T Function()? loading,
    T Function()? error,
    T Function()? success,
    T Function()? lucas,
    T Function()? giovanni,
  }) {
    final v = this;
    if (v == LoginStateStatus.initial && initial != null) {
      return initial();
    }

    if (v == LoginStateStatus.loading && loading != null) {
      return loading();
    }

    if (v == LoginStateStatus.error && error != null) {
      return error();
    }

    if (v == LoginStateStatus.success && success != null) {
      return success();
    }

    if (v == LoginStateStatus.lucas && lucas != null) {
      return lucas();
    }

    if (v == LoginStateStatus.giovanni && giovanni != null) {
      return giovanni();
    }

    return any();
  }
}
