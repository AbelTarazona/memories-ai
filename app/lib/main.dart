import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:memories/core/api/api_service.dart';
import 'package:memories/core/navigation/app_router.dart';
import 'package:memories/data/repositories/interfaces/i_remote_open_ai_repository.dart';
import 'package:memories/data/repositories/interfaces/i_remote_supabase_repository.dart';
import 'package:memories/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories/data/repositories/remote_open_ai_repository.dart';
import 'package:memories/data/repositories/remote_supabase_repository.dart';
import 'package:memories/data/repositories/supabase_repository.dart';
import 'package:memories/presentation/auth/bloc/auth_session_cubit.dart';
import 'package:memories/presentation/home/bloc/people_list_bloc.dart';
import 'package:memories/presentation/memories_list/bloc/memories_list_bloc.dart';
import 'package:memories/presentation/record_memory/bloc/analyze_memory_bloc.dart';
import 'package:memories/presentation/record_memory/bloc/transcript_save_memory_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await _initializeSupabase();
  final supabase = Supabase.instance.client;

  // Initialize Repositories and Services
  final supabaseRemoteService = ApiService(
    baseUrl: '${dotenv.env['SUPABASE_URL']}/functions/',
  );
  final openAiRemoteService = ApiService(
    baseUrl: 'https://api.openai.com/',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['OPEN_AI_TOKEN']}',
    },
  );
  final openAiRemote = RemoteOpenAIRepository(
    openAiService: openAiRemoteService,
    supabase: supabase,
  );
  final supabaseRemote = RemoteSupabaseRepository(
    supabaseService: supabaseRemoteService,
    supabase: supabase,
  );
  final authRepository = SupabaseRepository(supabase);

  // Initialize App Router and Auth Session Cubit
  final authSessionCubit = AuthSessionCubit(authRepository: authRepository)
    ..checkAuth();
  final appRouter = AppRouter(authSessionCubit: authSessionCubit);

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(
    MyApp(
      appRouter: appRouter,
      supabaseRepository: authRepository,
      remoteSupabaseRepository: supabaseRemote,
      remoteOpenAIRepository: openAiRemote,
    ),
  );
}

Future<void> _initializeSupabase() async {
  final anonymousKey = dotenv.env['SUPABASE_ANON_KEY'];
  final supabaseUrl = dotenv.env['SUPABASE_URL'];

  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: anonymousKey!,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      detectSessionInUri: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appRouter,
    required this.supabaseRepository,
    required this.remoteSupabaseRepository,
    required this.remoteOpenAIRepository,
  });

  final AppRouter appRouter;

  final SupabaseRepository supabaseRepository;

  final RemoteSupabaseRepository remoteSupabaseRepository;

  final RemoteOpenAIRepository remoteOpenAIRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ISupabaseRepository>.value(
          value: supabaseRepository,
        ),
        RepositoryProvider<IRemoteSupabaseRepository>.value(
          value: remoteSupabaseRepository,
        ),
        RepositoryProvider<IRemoteOpenAiRepository>.value(
          value: remoteOpenAIRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthSessionCubit(
              authRepository: context.read<ISupabaseRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TranscriptSaveMemoryBloc(
              repository: context.read<IRemoteSupabaseRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AnalyzeMemoryBloc(
              repository: context.read<IRemoteOpenAiRepository>(),
              supabaseRepository: context.read<IRemoteSupabaseRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => PeopleListBloc(
              repository: context.read<ISupabaseRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => MemoriesListBloc(
              repository: context.read<ISupabaseRepository>(),
            ),
          ),
        ],
        child: ShadApp.custom(
          themeMode: ThemeMode.light,
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadSlateColorScheme.dark(),
          ),
          appBuilder: (context) {
            return MaterialApp.router(
              routeInformationProvider:
                  appRouter.router.routeInformationProvider,
              routeInformationParser: appRouter.router.routeInformationParser,
              routerDelegate: appRouter.router.routerDelegate,
              debugShowCheckedModeBanner: false,
              theme: Theme.of(context),
              builder: (context, child) {
                return ShadAppBuilder(child: child!);
              },
            );
          },
        ),
      ),
    );
  }
}
