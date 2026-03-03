import 'package:fpdart/fpdart.dart';
import 'package:memories/core/failure.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/models/user_model.dart';

abstract class ISupabaseRepository {
  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> isAuthenticated();

  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, List<MemoryModel>>> memories();

  Future<Either<Failure, List<PeopleModel>>> people();
}
