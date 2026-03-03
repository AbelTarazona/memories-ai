/// Generic events
abstract class BaseEvent {
  const BaseEvent();
}

/// Event to trigger a fetch operation
class FetchEvent<P> extends BaseEvent {
  const FetchEvent([this.params]) : super();
  final P? params;
}

/// Event to reset the bloc to its initial state
class ResetEvent extends BaseEvent {
  const ResetEvent() : super();
}
