// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consult_product_bloc_state.dart';

// **************************************************************************
// MatchExtensionGenerator
// **************************************************************************

extension ConsultProductStateStatusMatch on ConsultProductStateStatus {
  T match<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function() error,
    required T Function() success,
  }) {
    final v = this;
    if (v == ConsultProductStateStatus.initial) {
      return initial();
    }

    if (v == ConsultProductStateStatus.loading) {
      return loading();
    }

    if (v == ConsultProductStateStatus.error) {
      return error();
    }

    if (v == ConsultProductStateStatus.success) {
      return success();
    }

    throw Exception(
      'ConsultProductStateStatus.match failed, found no match for: $this',
    );
  }

  T matchAny<T>({
    required T Function() any,
    T Function()? initial,
    T Function()? loading,
    T Function()? error,
    T Function()? success,
  }) {
    final v = this;
    if (v == ConsultProductStateStatus.initial && initial != null) {
      return initial();
    }

    if (v == ConsultProductStateStatus.loading && loading != null) {
      return loading();
    }

    if (v == ConsultProductStateStatus.error && error != null) {
      return error();
    }

    if (v == ConsultProductStateStatus.success && success != null) {
      return success();
    }

    return any();
  }
}
