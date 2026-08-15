// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'config.dart';
import 'models.dart';
import 'providers.dart';
import 'screens.dart';
import 'update_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _validateSecrets();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(const UpdateGate(child: ProviderScope(child: TribunalApp())));
}

void _validateSecrets() {
  if (SUPABASE_URL.isEmpty || SUPABASE_ANON_KEY.isEmpty) {
    throw Exception(
      'Supabase credentials not configured. '
      'Set SUPABASE_URL and SUPABASE_ANON_KEY in your environment.',
    );
  }
}

class TribunalApp extends ConsumerWidget {
  const TribunalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp.router(
      title: 'Tribunal',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      // Force left-to-right layout app-wide. Some device locales/keyboards
      // can otherwise flip text entry direction inside text fields.
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: _buildRouter(authState),
    );
  }

  GoRouter _buildRouter(AsyncValue<UserProfile?> authState) {
    return GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) {
            return authState.when(
              data: (user) {
                if (user == null) return const LoginScreen();

                final currentAuthUser =
                    Supabase.instance.client.auth.currentUser;
                final otpVerified =
                    currentAuthUser?.userMetadata?['trib_otp_verified'] ==
                        true;

                return otpVerified ? const HomeScreen() : const OtpScreen();
              },
              loading: () => const LoadingScreen(),
              error: (err, stack) => ErrorScreen(error: err.toString()),
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/otp',
          builder: (context, state) => const OtpScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/overview/:id',
          builder: (context, state) {
            final overviewId = state.pathParameters['id']!;
            return OverviewDetailScreen(overviewId: overviewId);
          },
        ),
        GoRoute(
          path: '/review/:overviewId/:expertId',
          builder: (context, state) {
            final overviewId = state.pathParameters['overviewId']!;
            final expertId = state.pathParameters['expertId']!;
            return ReviewFormScreen(
              overviewId: overviewId,
              expertId: expertId,
            );
          },
        ),
      ],
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      typography: Typography.material2021(
        platform: TargetPlatform.android,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
        ),
      ),
    );
  }
}
