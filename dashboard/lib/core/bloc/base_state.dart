import 'package:equatable/equatable.dart';
import 'package:memories_web_admin/core/failure.dart';

abstract class BaseState<T> extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

class InitialState<T> extends BaseState<T> {
  const InitialState();
}

class LoadingState<T> extends BaseState<T> {
  const LoadingState();
}

class LoadedState<T> extends BaseState<T> {
  final T data;

  const LoadedState(this.data);

  @override
  List<Object?> get props => [data];
}

class ErrorState<T> extends BaseState<T> {
  final Failure failure;

  const ErrorState(this.failure);

  @override
  List<Object?> get props => [failure];
}
