import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/daily_mood_model.dart';
import 'package:memories_web_admin/data/models/insights_model.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/models/memory_search_model.dart';
import 'package:memories_web_admin/data/models/people_model.dart';
import 'package:memories_web_admin/data/models/person_insight_model.dart';
import 'package:memories_web_admin/data/models/person_traits_model.dart';
import 'package:memories_web_admin/data/models/user_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:memories_web_admin/data/models/graph_model.dart';
import 'package:memories_web_admin/data/models/memory_question_model.dart';
import 'package:memories_web_admin/data/models/memory_notes_model.dart';

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
  Future<Either<Failure, List<MemoryModel>>> memories({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('memories').select().eq('is_enable', true);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response =
          await query.order('created_at', ascending: false) as List<dynamic>;
      final memories = response
          .map((memory) => MemoryModel.fromMap(memory as Map<String, dynamic>))
          .toList();
      return right(memories);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemoryModel>> memoryById(int id) async {
    try {
      final response = await _supabase
          .from('memories')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) {
        return left(Failure('No se encontró la memoria solicitada.'));
      }
      return right(MemoryModel.fromMap(Map<String, dynamic>.from(response)));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PeopleModel>>> people({
    String? gender,
    String? searchTerm,
  }) async {
    try {
      var query = _supabase.from('people').select();

      if (gender != null) {
        query = query.eq('gender', gender);
      }

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query.or(
          'display_name.ilike.%$searchTerm%,alias.ilike.%$searchTerm%',
        );
      }

      final response =
          await query.order('created_at', ascending: false) as List<dynamic>;
      final people = response
          .map((person) => PeopleModel.fromJson(person as Map<String, dynamic>))
          .toList();
      return right(people);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createPerson({
    required String displayName,
    required PersonTraitsModel traits,
    String? alias,
    String? gender,
    String? ageRange,
    String? height,
  }) async {
    try {
      await _supabase.from('people').insert({
        'owner_user_id': 'aeeab61b-3554-44f8-966a-8754559402d3',
        'display_name': displayName,
        'traits': traits.toMap(),
        'alias': alias,
        'gender': gender,
        'age_range': ageRange,
        'height_cm': height,
      });

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePerson({
    required String id,
    required String displayName,
    required PersonTraitsModel traits,
    String? alias,
    String? gender,
    String? ageRange,
    String? height,
  }) async {
    try {
      await _supabase
          .from('people')
          .update({
            'display_name': displayName,
            'traits': traits.toMap(),
            'alias': alias,
            'gender': gender,
            'age_range': ageRange,
            'height_cm': height,
          })
          .eq('id', id);

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemorySearchModel>>> searchMemories({
    required String query,
  }) async {
    final body = {
      "query": query,
      "limit": 5,
      //"debug": true, // Temporal para diagnóstico
    };

    try {
      final res = await _supabase.functions.invoke(
        'search-memories',
        body: body,
      );

      log(
        'Raw response: ${res.data}',
        name: 'SupabaseRepository.searchMemories',
      );

      final data = res.data['data'] as List<dynamic>?;

      if (data == null || data.isEmpty) {
        log(
          'No data found in response',
          name: 'SupabaseRepository.searchMemories',
        );
        return right([]);
      }

      final memories = data
          .map((e) => MemorySearchModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return right(memories);
    } catch (e) {
      log(e.toString(), name: 'SupabaseRepository.searchMemories');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InsightsModel>> insights() async {
    try {
      final peopleFuture = _supabase
          .from('people')
          .select()
          .eq(
            'owner_user_id',
            'aeeab61b-3554-44f8-966a-8754559402d3',
          );

      final feelingPredominantFuture = _supabase.rpc(
        'top_feelings',
        params: {
          'limit_count': 1,
        },
      );

      final longestMemoryStreakFuture = _supabase.rpc(
        'get_longest_memory_streak',
      );

      final lastMemoryDateFuture = _supabase.rpc(
        'get_last_memory_date',
      );

      final dailyMoodFuture = _supabase.rpc(
        'get_daily_mood',
      );

      final results = await Future.wait([
        peopleFuture,
        feelingPredominantFuture,
        longestMemoryStreakFuture,
        lastMemoryDateFuture,
        dailyMoodFuture,
      ]);

      final people = results[0];
      final feelingPredominant = results[1];
      final longestMemoryStreak = results[2];
      final lastMemoryDate = results[3];
      final dailyMood = results[4];

      final peopleCount = (people as List).length.toString();

      String feeling = '';
      final feelingList = (feelingPredominant as List)
          .cast<Map<String, dynamic>>();
      if (feelingList.isNotEmpty) {
        final feelingData = feelingList.first;
        feeling = feelingData['feeling'] as String;
      }

      String memoryStreak = '';
      final streakList = (longestMemoryStreak as List)
          .cast<Map<String, dynamic>>();
      if (streakList.isNotEmpty) {
        final streakData = streakList.first;
        memoryStreak = streakData['longest_streak_days']?.toString() ?? '';
      }

      String lastMemory = '';
      final lastMemoryDateData = lastMemoryDate as String?;
      if (lastMemoryDateData != null) {
        lastMemory = lastMemoryDateData;
      }

      List<DailyMoodModel> dailyMoodList = [];
      final dailyMoodListData = (dailyMood as List)
          .cast<Map<String, dynamic>>();
      for (var moodData in dailyMoodListData) {
        dailyMoodList.add(DailyMoodModel.fromJson(moodData));
      }

      final data = InsightsModel(
        peopleMentionedQuantity: peopleCount,
        feelingPredominant: feeling,
        currentStreak: memoryStreak,
        lastMemoryDate: lastMemory,
        dailyMood: dailyMoodList,
      );

      return right(data);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GraphData>> getPeopleCooccurrenceGraph() async {
    try {
      // 1. Fetch valid memory IDs (is_enable = true)
      // Note: We select only the ID to minimize transfer
      final memoriesResponse = await _supabase
          .from('memories')
          .select('id')
          .eq('is_enable', true);

      final validMemoryIds = (memoriesResponse as List<dynamic>)
          .map((m) => m['id'] as int)
          .toSet();

      // 2. Fetch people to get names (limit 1000 should be fine for now, but good to be aware)
      final peopleResponse =
          await _supabase.from('people').select() as List<dynamic>;

      final peopleMap = {
        for (var p in peopleResponse)
          p['id'] as String: GraphNode(
            id: p['id'] as String,
            label: p['display_name'] as String,
          ),
      };

      // 3. Fetch memory_person associations
      // We could filter strictly by validMemoryIds here if the list is small,
      // or fetch all and filter in Dart if memory_person table is not huge.
      // For scalability, let's fetch all and filter in memory since we can't easily do "IN large_list"
      // If table grows > 1000, we need pagination or logic change.
      // Let's use a higher limit just in case.
      final relationsResponse =
          await _supabase.from('memory_person').select().limit(5000)
              as List<dynamic>;

      // 4. Group by memory_id, considering ONLY valid memories
      final Map<int, List<String>> memoryPeople = {};

      for (var relation in relationsResponse) {
        final memoryId = relation['memory_id'] as int;

        // Filter out disabled memories
        if (!validMemoryIds.contains(memoryId)) continue;

        final personId = relation['person_id'] as String;
        if (!peopleMap.containsKey(personId)) continue;

        memoryPeople.putIfAbsent(memoryId, () => []).add(personId);
      }

      // 5. Calculate co-occurrences and active nodes
      final Map<String, int> coOccurrences = {};
      final Set<String> activePersonIds = {};

      for (var peopleList in memoryPeople.values) {
        // Add ALL people found in valid memories, even if they are alone
        activePersonIds.addAll(peopleList);

        if (peopleList.length < 2) continue;

        // Sort to ensure consistent pairs
        peopleList.sort();

        // Generate combinations
        for (var i = 0; i < peopleList.length; i++) {
          for (var j = i + 1; j < peopleList.length; j++) {
            final p1 = peopleList[i];
            final p2 = peopleList[j];
            final key = '$p1|$p2';

            coOccurrences[key] = (coOccurrences[key] ?? 0) + 1;
            // activePersonIds.add(p1); // Already added above
            // activePersonIds.add(p2); // Already added above
          }
        }
      }

      // Build graph data
      final nodes = activePersonIds.map((id) => peopleMap[id]!).toList();
      final links = coOccurrences.entries.map((entry) {
        final parts = entry.key.split('|');
        return GraphLink(
          source: parts[0],
          target: parts[1],
          weight: entry.value,
        );
      }).toList();

      return right(GraphData(nodes: nodes, links: links));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemoryQuestionModel>>> getMemoryQuestions(
    int memoryId,
  ) async {
    try {
      final response =
          await _supabase
                  .from('memory_questions')
                  .select()
                  .eq('memory_id', memoryId)
                  .order('created_at', ascending: true)
              as List<dynamic>;

      final questions = response
          .map(
            (q) => MemoryQuestionModel.fromMap(q as Map<String, dynamic>),
          )
          .toList();
      return right(questions);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemoryQuestionModel>> saveMemoryQuestion({
    required int memoryId,
    required String question,
    String? answer,
  }) async {
    try {
      final response = await _supabase
          .from('memory_questions')
          .insert({
            'memory_id': memoryId,
            'question': question,
            'user_answer': answer,
            'answered': answer != null && answer.isNotEmpty,
          })
          .select()
          .single();

      return right(
        MemoryQuestionModel.fromMap(response as Map<String, dynamic>),
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemoryQuestion(
    MemoryQuestionModel question,
  ) async {
    try {
      await _supabase
          .from('memory_questions')
          .update(question.toMap())
          .eq('id', question.id);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMemoryQuestion(int id) async {
    try {
      await _supabase.from('memory_questions').delete().eq('id', id);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePerson(String id) async {
    try {
      await _supabase.from('people').delete().eq('id', id);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemory(MemoryModel memory) async {
    try {
      await _supabase
          .from('memories')
          .update(memory.toMap())
          .eq('id', memory.id);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Get all memories where a specific person is mentioned
  Future<Either<Failure, List<MemoryModel>>> memoriesByPerson({
    required String personName,
  }) async {
    try {
      final response =
          await _supabase
                  .from('memories')
                  .select()
                  .eq('is_enable', true)
                  .contains('ai_people', [personName])
                  .order('created_at', ascending: false)
              as List<dynamic>;

      final memories = response
          .map((memory) => MemoryModel.fromMap(memory as Map<String, dynamic>))
          .toList();
      return right(memories);
    } catch (e) {
      log(e.toString(), name: 'SupabaseRepository.memoriesByPerson');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonInsightModel?>> getPersonInsights(
    String personId,
  ) async {
    try {
      final response = await _supabase
          .from('person_insights')
          .select()
          .eq('person_id', personId)
          .maybeSingle();

      if (response == null) {
        return right(null);
      }

      return right(
        PersonInsightModel.fromJson(response as Map<String, dynamic>),
      );
    } catch (e) {
      log(e.toString(), name: 'SupabaseRepository.getPersonInsights');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePersonInsights(
    PersonInsightModel insight,
  ) async {
    try {
      final json = insight.toJson();
      // Inject current user_id or fallback to hardcoded ID (matching existing patterns in repo)
      final userId =
          _supabase.auth.currentUser?.id ??
          'aeeab61b-3554-44f8-966a-8754559402d3';
      json['user_id'] = userId;

      // Remove fields that might be null and cause issues
      json.removeWhere((key, value) => value == null);

      await _supabase.from('person_insights').upsert(json);
      return right(null);
    } catch (e) {
      log(e.toString(), name: 'SupabaseRepository.savePersonInsights');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemoryModel>>> getMemoriesForPerson(
    String personId,
  ) async {
    try {
      // Removing explicit user_id filter to match other methods pattern (relying on RLS or personId uniqueness)
      // because _supabase.auth.currentUser is null in this environment context.

      final response = await _supabase
          .from('memories')
          .select('*, memory_person!inner(*)')
          .eq('is_enable', true)
          .eq('memory_person.person_id', personId)
          .order('created_at', ascending: true);

      final memories = (response as List<dynamic>)
          .map((m) => MemoryModel.fromMap(m as Map<String, dynamic>))
          .toList();

      return right(memories);
    } catch (e) {
      log(e.toString(), name: 'SupabaseRepository.getMemoriesForPerson');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveMemoryNotes(
    List<MemoryNoteModel> notes,
  ) async {
    try {
      if (notes.isEmpty) return right(null);
      await _supabase
          .from('memory_notes')
          .insert(notes.map((n) => n.toJson()).toList());
      return right(null);
    } catch (e) {
      log(e.toString(), name: 'SupabaseRepository.saveMemoryNotes');
      return left(Failure(e.toString()));
    }
  }
}
