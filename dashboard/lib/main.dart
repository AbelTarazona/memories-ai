import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memories_web_admin/core/api/api_service.dart';
import 'package:memories_web_admin/core/navigation/app_router.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/data/repositories/open_ai_repository.dart';
import 'package:memories_web_admin/data/repositories/supabase_repository.dart';
import 'package:memories_web_admin/data/repositories/langchain_open_ai_repository.dart';
import 'package:memories_web_admin/presentation/auth/bloc/auth_session_cubit.dart';
import 'package:memories_web_admin/presentation/home/bloc/insights_bloc.dart';
import 'package:memories_web_admin/presentation/home/bloc/network_graph_bloc.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memories_list_bloc.dart';
import 'package:memories_web_admin/presentation/people/bloc/people_list_bloc.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await dotenv.load(fileName: ".env");
  await _initializeSupabase();
  final supabase = Supabase.instance.client;
  final chatOpenAI = ChatOpenAI(
    apiKey: dotenv.env['OPEN_AI_TOKEN']!,
    defaultOptions: const ChatOpenAIOptions(
      model: 'gpt-4o-mini',
      temperature: 0.7,
    ),
  );

  final supabaseRemoteService = ApiService(
    baseUrl: '${dotenv.env['SUPABASE_URL']}/functions/',
    /*    headers: {
      'Content-Type': 'application/json',
    }*/
  );
  final authRepository = SupabaseRepository(
    supabase,
  );

  final openAiRepository = LangchainOpenAiRepository(
    chatOpenAI,
    authRepository,
  );

  final authSessionCubit = AuthSessionCubit(authRepository: authRepository)
    ..checkAuth();
  final appRouter = AppRouter(authSessionCubit: authSessionCubit);
  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(
    MyApp(
      appRouter: appRouter,
      supabaseRepository: authRepository,
      openAiRepository: openAiRepository,
      authSessionCubit: authSessionCubit,
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
    required this.openAiRepository,
    required this.authSessionCubit,
  });

  final AppRouter appRouter;

  final SupabaseRepository supabaseRepository;

  final IOpenAIRepository openAiRepository;

  final AuthSessionCubit authSessionCubit;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ISupabaseRepository>.value(
          value: supabaseRepository,
        ),
        RepositoryProvider<IOpenAIRepository>.value(value: openAiRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthSessionCubit>.value(value: authSessionCubit),
          BlocProvider<PeopleListBloc>(
            create: (context) => PeopleListBloc(repository: supabaseRepository),
          ),
          BlocProvider<MemoriesListBloc>(
            create: (context) =>
                MemoriesListBloc(repository: supabaseRepository),
          ),
          BlocProvider<InsightsBloc>(
            create: (context) => InsightsBloc(repository: supabaseRepository),
          ),
          BlocProvider<NetworkGraphBloc>(
            create: (context) =>
                NetworkGraphBloc(repository: supabaseRepository),
          ),
        ],
        child: ShadApp.custom(
          themeMode: ThemeMode.light,
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadSlateColorScheme.dark(),
            textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.nunitoSans),
          ),
          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadSlateColorScheme.light(),
            textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.nunitoSans),
          ),
          appBuilder: (context) {
            return MaterialApp.router(
              routeInformationProvider:
                  appRouter.router.routeInformationProvider,
              routeInformationParser: appRouter.router.routeInformationParser,
              routerDelegate: appRouter.router.routerDelegate,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'),
                Locale('es'),
              ],
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
