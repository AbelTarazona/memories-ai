abstract class PersonInsightsEvent {}

class FetchPersonInsights extends PersonInsightsEvent {
  final String personId;
  final String personName;

  final bool forceReload;

  FetchPersonInsights({
    required this.personId,
    required this.personName,
    this.forceReload = false,
  });
}
