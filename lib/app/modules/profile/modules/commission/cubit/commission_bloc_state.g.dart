// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_bloc_state.dart';

// **************************************************************************
// MatchExtensionGenerator
// **************************************************************************

extension CommissionBlocStatusMatch on CommissionBlocStatus {
  T match<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function() success,
    required T Function() error,
  }) {
    final v = this;
    if (v == CommissionBlocStatus.initial) {
      return initial();
    }

    if (v == CommissionBlocStatus.loading) {
      return loading();
    }

    if (v == CommissionBlocStatus.success) {
      return success();
    }

    if (v == CommissionBlocStatus.error) {
      return error();
    }

    throw Exception(
      'CommissionBlocStatus.match failed, found no match for: $this',
    );
  }

  T matchAny<T>({
    required T Function() any,
    T Function()? initial,
    T Function()? loading,
    T Function()? success,
    T Function()? error,
  }) {
    final v = this;
    if (v == CommissionBlocStatus.initial && initial != null) {
      return initial();
    }

    if (v == CommissionBlocStatus.loading && loading != null) {
      return loading();
    }

    if (v == CommissionBlocStatus.success && success != null) {
      return success();
    }

    if (v == CommissionBlocStatus.error && error != null) {
      return error();
    }

    return any();
  }
}
