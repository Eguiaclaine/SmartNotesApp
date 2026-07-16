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
      child: _NoteVaultRoot(supabaseReady: supabaseReady),
    );
  }
}

/// Hosts auth + optional session providers ABOVE MaterialApp so every pushed
/// route (Note Editor, Life Spaces, Profile) can read Notes/Spaces/Profile.
class _NoteVaultRoot extends StatelessWidget {
  const _NoteVaultRoot({required this.supabaseReady});

  final bool supabaseReady;

  @override
  Widget build(BuildContext context) {
    if (!supabaseReady) {
      return MaterialApp(
        title: 'NoteVault',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.light(),
        home: const _BackendUnavailableScreen(),
      );
    }

    final authProvider = context.watch<app_auth.AuthProvider>();

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;
        final user = session?.user;

        // Logged out (or waiting for first session)
        if (user == null) {
          final home = authProvider.isTransitioning
              ? AppLoadingScreen(
                  message: authProvider.loadingMessage,
                  icon: _loadingIcon(authProvider.loadingPhase),
                )
              : snapshot.connectionState == ConnectionState.waiting
                  ? const AppLoadingScreen(message: 'Loading NoteVault...')
                  : const AuthScreen();

          return MaterialApp(
            key: const ValueKey('notevault-auth-shell'),
            title: 'NoteVault',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: AppTheme.light(),
            home: home,
          );
        }

        // Logged in: session providers wrap MaterialApp so Note Editor / Spaces /
        // Profile routes always find SpacesProvider + friends.
        return _SessionScope(
          key: ValueKey('session-scope-${user.id}'),
          userId: user.id,
          child: MaterialApp(
            key: const ValueKey('notevault-main-shell'),
            title: 'NoteVault',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: AppTheme.light(),
            // Never replace this home while logged in — swapping to a loading
            // screen disposed pushed routes and triggered `_dependents.isEmpty`.
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
      app_auth.AuthLoadingPhase.none => Icons.lock_rounded,
    };
  }
}

/// Owns session ChangeNotifiers so they are not recreated/disposed on every
/// auth stream tick (TOKEN_REFRESHED), which caused `_dependents.isEmpty`.
class _SessionScope extends StatefulWidget {
  const _SessionScope({
    super.key,
    required this.userId,
    required this.child,
  });

  final String userId;
  final Widget child;

  @override
  State<_SessionScope> createState() => _SessionScopeState();
}

class _SessionScopeState extends State<_SessionScope> {
  late final NotesProvider _notes =
      NotesProvider(widget.userId, supabaseReady: true);
  late final SpacesProvider _spaces =
      SpacesProvider(widget.userId, supabaseReady: true);
  late final ProfileProvider _profile =
      ProfileProvider(widget.userId, supabaseReady: true);

  @override
  void dispose() {
    _notes.dispose();
    _spaces.dispose();
    _profile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NotesProvider>.value(value: _notes),
        ChangeNotifierProvider<SpacesProvider>.value(value: _spaces),
        ChangeNotifierProvider<ProfileProvider>.value(value: _profile),
      ],
      child: widget.child,
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
