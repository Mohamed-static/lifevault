import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:shared_preferences/shared_preferences.dart";
import "core/theme.dart";
import "services/supabase_service.dart";
import "services/notification_service.dart";
import "features/auth/screens/login_screen.dart";
import "features/home/screens/home_screen.dart";
import "features/splash/screens/splash_screen.dart";

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(url: dotenv.env["SUPABASE_URL"]!, publishableKey: dotenv.env["SUPABASE_ANON_KEY"]!);
  await NotificationService.init();
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString("theme_mode");
  if (savedTheme == "light") themeModeNotifier.value = ThemeMode.light;
  runApp(const LifeVaultApp());
}

Future<void> toggleTheme() async {
  final prefs = await SharedPreferences.getInstance();
  if (themeModeNotifier.value == ThemeMode.dark) {
    themeModeNotifier.value = ThemeMode.light;
    await prefs.setString("theme_mode", "light");
  } else {
    themeModeNotifier.value = ThemeMode.dark;
    await prefs.setString("theme_mode", "dark");
  }
}

class LifeVaultApp extends StatelessWidget {
  const LifeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: "LifeVault",
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = SupabaseService.client.auth.currentSession;
        if (session != null) return const HomeScreen();
        return const LoginScreen();
      },
    );
  }
}