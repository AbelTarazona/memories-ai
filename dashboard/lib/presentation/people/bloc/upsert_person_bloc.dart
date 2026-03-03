import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/data/models/person_traits_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class UpsertPersonParameters {
  final String? id;
  final String displayName;
  final PersonTraitsModel traits;
  final String? alias;
  final String? gender;
  final String? ageRange;
  final String? height;

  const UpsertPersonParameters({
    this.id,
    required this.displayName,
    required this.traits,
    this.alias,
    this.gender,
    this.ageRange,
    this.height,
  });

  bool get isUpdate => id != null;
}

class UpsertPersonBloc extends GenericBloc<UpsertPersonParameters, void> {
  UpsertPersonBloc({required ISupabaseRepository repository})
      : super(
          fetchFunction: (params) async {
            if (params == null) {
              throw Exception('Parameters cannot be null');
            }

            if (params.isUpdate) {
              return repository.updatePerson(
                id: params.id!,
                displayName: params.displayName,
                traits: params.traits,
                alias: params.alias,
                gender: params.gender,
                ageRange: params.ageRange,
                height: params.height,
              );
            }

            return repository.createPerson(
              displayName: params.displayName,
              traits: params.traits,
              alias: params.alias,
              gender: params.gender,
              ageRange: params.ageRange,
              height: params.height,
            );
          },
        );
}
