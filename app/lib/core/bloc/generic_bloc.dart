import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:memories/core/bloc/base_state.dart';
import 'package:memories/core/bloc/fetch_event.dart';
import 'package:memories/core/failure.dart';

class GenericBloc<P, T> extends Bloc<BaseEvent, BaseState<T>> {
  final Future<Either<Failure, T>> Function(P? params) fetchFunction;

  GenericBloc({required this.fetchFunction}) : super(InitialState<T>()) {
    on<FetchEvent<P>>(_onFetch);
    on<ResetEvent>(_onReset);
  }

  Future<void> _onFetch(FetchEvent<P> event, Emitter<BaseState<T>> emit) async {
    emit(LoadingState<T>());
    final either = await fetchFunction(event.params);
    either.fold(
      (failure) => emit(ErrorState<T>(failure)),
      (data) => emit(LoadedState<T>(data)),
    );
  }

  void _onReset(ResetEvent event, Emitter<BaseState<T>> emit) {
    emit(InitialState<T>());
  }
}
