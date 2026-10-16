// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_bloc_state.dart';

// **************************************************************************
// MatchExtensionGenerator
// **************************************************************************

extension FinishCartStatusMatch on FinishCartStatus {
  T match<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function() error,
    required T Function() success,
  }) {
    final v = this;
    if (v == FinishCartStatus.initial) {
      return initial();
    }

    if (v == FinishCartStatus.loading) {
      return loading();
    }

    if (v == FinishCartStatus.error) {
      return error();
    }

    if (v == FinishCartStatus.success) {
      return success();
    }

    throw Exception('FinishCartStatus.match failed, found no match for: $this');
  }

  T matchAny<T>({
    required T Function() any,
    T Function()? initial,
    T Function()? loading,
    T Function()? error,
    T Function()? success,
  }) {
    final v = this;
    if (v == FinishCartStatus.initial && initial != null) {
      return initial();
    }

    if (v == FinishCartStatus.loading && loading != null) {
      return loading();
    }

    if (v == FinishCartStatus.error && error != null) {
      return error();
    }

    if (v == FinishCartStatus.success && success != null) {
      return success();
    }

    return any();
  }
}
