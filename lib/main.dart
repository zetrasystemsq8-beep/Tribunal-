import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'providers.dart';
import 'screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );
  
  runApp(const ProviderScope(child: TribunalApp()));
}

class TribunalApp extends ConsumerWidget {
  const TribunalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Tribunal',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: authState.when(
        data: (user) {
          if (user == null) return const LoginScreen();
          // Check if OTP verified
          final otpVerified = user.userMetadata?['trib_otp_verified'] == true;
          return otpVerified ? const HomeScreen() : const OtpScreen();
        },
        loading: () => const LoadingScreen(),
        error: (err, stack) => ErrorScreen(error: err.toString()),
      ),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
