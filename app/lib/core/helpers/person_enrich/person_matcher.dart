import 'package:memories/data/models/people_model.dart';

abstract class PersonMatcher {
  PeopleModel? findMatchingPerson(
    String personName,
    List<PeopleModel> peopleList, {
    double similarityThreshold = 0.8, // 0..1
  });
}
