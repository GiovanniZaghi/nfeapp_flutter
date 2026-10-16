// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_bloc_state.dart';

// **************************************************************************
// MatchExtensionGenerator
// **************************************************************************

extension OrderStateStatusMatch on OrderStateStatus {
  T match<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function() error,
    required T Function() success,
  }) {
    final v = this;
    if (v == OrderStateStatus.initial) {
      return initial();
    }

    if (v == OrderStateStatus.loading) {
      return loading();
    }

    if (v == OrderStateStatus.error) {
      return error();
    }

    if (v == OrderStateStatus.success) {
      return success();
    }

    throw Exception('OrderStateStatus.match failed, found no match for: $this');
  }

  T matchAny<T>({
    required T Function() any,
    T Function()? initial,
    T Function()? loading,
    T Function()? error,
    T Function()? success,
  }) {
    final v = this;
    if (v == OrderStateStatus.initial && initial != null) {
      return initial();
    }

    if (v == OrderStateStatus.loading && loading != null) {
      return loading();
    }

    if (v == OrderStateStatus.error && error != null) {
      return error();
    }

    if (v == OrderStateStatus.success && success != null) {
      return success();
    }

    return any();
  }
}
