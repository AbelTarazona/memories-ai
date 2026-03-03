import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:memories/core/failure.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/models/user_model.dart';
import 'package:memories/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRepository implements ISupabaseRepository {
  final SupabaseClient _supabase;

  SupabaseRepository(this._supabase);

  @override
  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return right(null);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final response = await _supabase.auth.getUser();
      final isAuthenticated = response.user != null;
      return right(isAuthenticated);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw 'User not authenticated';
      }
      final response = await _supabase
          .from('users')
          .select('*, company:companies(*), project_users(*, projects(*))')
          .eq('id', userId)
          .single();
      final Map<String, dynamic> data = response;
      final user = UserModel.fromJson(data);
      return right(user);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return right(null);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemoryModel>>> memories() async {
    try {
      final response = await _supabase.from('memories').select().eq('is_enable', true).order('created_at', ascending: false) as List<dynamic>;
      final memories = response.map((memory) => MemoryModel.fromMap(memory as Map<String, dynamic>)).toList();
      return right(memories);
    } catch (e) {
      log(e.toString());
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PeopleModel>>> people() async {
    try {
      final response = await _supabase.from('people').select().order('created_at', ascending: false) as List<dynamic>;
      final people = response.map((person) => PeopleModel.fromJson(person as Map<String, dynamic>)).toList();
      return right(people);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
