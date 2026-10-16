// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_bloc_state.dart';

// **************************************************************************
// MatchExtensionGenerator
// **************************************************************************

extension CustomerStateStatusMatch on CustomerStateStatus {
  T match<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function() error,
    required T Function() success,
  }) {
    final v = this;
    if (v == CustomerStateStatus.initial) {
      return initial();
    }

    if (v == CustomerStateStatus.loading) {
      return loading();
    }

    if (v == CustomerStateStatus.error) {
      return error();
    }

    if (v == CustomerStateStatus.success) {
      return success();
    }

    throw Exception(
      'CustomerStateStatus.match failed, found no match for: $this',
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
    if (v == CustomerStateStatus.initial && initial != null) {
      return initial();
    }

    if (v == CustomerStateStatus.loading && loading != null) {
      return loading();
    }

    if (v == CustomerStateStatus.error && error != null) {
      return error();
    }

    if (v == CustomerStateStatus.success && success != null) {
      return success();
    }

    return any();
  }
}
