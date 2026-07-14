import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:application/providers/auth_provider.dart' as app_auth;
import 'package:application/providers/notes_provider.dart';
import 'package:application/providers/profile_provider.dart';
import 'package:application/providers/theme_provider.dart';
import 'package:application/screens/auth_screen.dart';
import 'package:application/screens/notes_home_screen.dart';
import 'package:application/services/notification_service.dart';
import 'package:application/services/supabase_service.dart';
import 'package:application/theme/app_theme.dart';
import 'package:application/widgets/app_loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  try {
    await NotificationService.instance.initialize();
  } catch (_) {}
  final supabaseReady = await SupabaseService.initialize();
  runApp(SmartNotesApp(supabaseReady: supabaseReady));
}

class SmartNotesApp extends StatelessWidget {
  const SmartNotesApp({super.key, required this.supabaseReady});

  final bool supabaseReady;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
      ],
      child: SmartNotesView(supabaseReady: supabaseReady),
    );
  }
}

class SmartNotesView extends StatelessWidget {
  const SmartNotesView({super.key, required this.supabaseReady});

  final bool supabaseReady;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<app_auth.AuthProvider>();

    if (!supabaseReady) {
      return _buildMaterialApp(
        themeProvider,
        home: const _BackendUnavailableScreen(),
      );
    }

    if (authProvider.isTransitioning) {
      return _buildMaterialApp(
        themeProvider,
        home: AppLoadingScreen(
          message: authProvider.loadingMessage,
          icon: _loadingIcon(authProvider.loadingPhase),
        ),
      );
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          return _buildMaterialApp(
            themeProvider,
            home: const AppLoadingScreen(
              message: 'Loading Smart Notes...',
            ),
          );
        }

        final user = session?.user;
        if (user == null) {
          return _buildMaterialApp(themeProvider, home: const AuthScreen());
        }

        return MultiProvider(
          key: ValueKey(user.id),
          providers: [
            ChangeNotifierProvider(
              create: (_) => NotesProvider(user.id, supabaseReady: true),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(user.id, supabaseReady: true),
            ),
          ],
          child: _buildMaterialApp(
            themeProvider,
            home: const NotesHomeScreen(),
          ),
        );
      },
    );
  }

  IconData _loadingIcon(app_auth.AuthLoadingPhase phase) {
    return switch (phase) {
      app_auth.AuthLoadingPhase.signingOut => Icons.logout_rounded,
      app_auth.AuthLoadingPhase.signingIn => Icons.login_rounded,
      app_auth.AuthLoadingPhase.signingUp => Icons.person_add_alt_1_rounded,
      app_auth.AuthLoadingPhase.none => Icons.edit_note_rounded,
    };
  }

  Widget _buildMaterialApp(ThemeProvider themeProvider, {required Widget home}) {
    return MaterialApp(
      title: 'Smart Notes',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: home,
    );
  }
}

class _BackendUnavailableScreen extends StatelessWidget {
  const _BackendUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 56, color: scheme.error),
                  const SizedBox(height: 20),
                  Text(
                    'Backend not configured',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Copy .env.example to .env and set SUPABASE_URL and SUPABASE_ANON_KEY, then restart the app.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef DailyLogApp = SmartNotesApp;
