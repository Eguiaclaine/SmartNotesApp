import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:application/providers/auth_provider.dart' as app_auth;
import 'package:application/providers/notes_provider.dart';
import 'package:application/providers/profile_provider.dart';
import 'package:application/providers/spaces_provider.dart';
import 'package:application/screens/auth_screen.dart';
import 'package:application/screens/notes_home_screen.dart';
import 'package:application/services/notification_service.dart';
import 'package:application/services/supabase_service.dart';
import 'package:application/theme/app_theme.dart';
import 'package:application/widgets/app_loading_screen.dart';
import 'package:application/widgets/candy_ui.dart';

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
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
      ],
      // One stable MaterialApp. Session providers live under a nested Navigator
      // so pushed screens (NoteEditor, Life Spaces, Profile) still see them.
      child: MaterialApp(
        title: 'NoteVault',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.light(),
        home: _AppRoot(supabaseReady: supabaseReady),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot({required this.supabaseReady});

  final bool supabaseReady;

  @override
  Widget build(BuildContext context) {
    if (!supabaseReady) {
      return const _BackendUnavailableScreen();
    }

    final authProvider = context.watch<app_auth.AuthProvider>();

    if (authProvider.isTransitioning) {
      return AppLoadingScreen(
        message: authProvider.loadingMessage,
        icon: _loadingIcon(authProvider.loadingPhase),
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
          return const AppLoadingScreen(message: 'Loading NoteVault...');
        }

        final user = session?.user;
        if (user == null) {
          return const AuthScreen();
        }

        return MultiProvider(
          key: ValueKey('session-${user.id}'),
          providers: [
            ChangeNotifierProvider(
              create: (_) => NotesProvider(user.id, supabaseReady: true),
            ),
            ChangeNotifierProvider(
              create: (_) => SpacesProvider(user.id, supabaseReady: true),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(user.id, supabaseReady: true),
            ),
          ],
          // Nested navigator keeps NoteEditor / Spaces / Profile under providers.
          child: const _AuthenticatedNavigator(),
        );
      },
    );
  }

  IconData _loadingIcon(app_auth.AuthLoadingPhase phase) {
    return switch (phase) {
      app_auth.AuthLoadingPhase.signingOut => Icons.logout_rounded,
      app_auth.AuthLoadingPhase.signingIn => Icons.login_rounded,
      app_auth.AuthLoadingPhase.signingUp => Icons.person_add_alt_1_rounded,
      app_auth.AuthLoadingPhase.none => Icons.lock_rounded,
    };
  }
}

/// Hosts app routes under session providers (Notes / Spaces / Profile).
class _AuthenticatedNavigator extends StatelessWidget {
  const _AuthenticatedNavigator();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NotesHomeScreen(),
        );
      },
    );
  }
}

class _BackendUnavailableScreen extends StatelessWidget {
  const _BackendUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CandyBody(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.error.withValues(alpha: 0.1),
                      ),
                      child: Icon(Icons.cloud_off_rounded, size: 48, color: scheme.error),
                    ),
                    const SizedBox(height: 22),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef DailyLogApp = SmartNotesApp;
