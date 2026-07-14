import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  String? _registeredEmail;

  void _switchToLogin({String? email}) {
    setState(() {
      _isLogin = true;
      if (email != null) _registeredEmail = email;
    });
  }

  void _switchToRegister() {
    context.read<AuthProvider>().clearMessages();
    setState(() {
      _isLogin = false;
      _registeredEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.candyBlush,
              AppColors.lightBackground,
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: pagePadding(context),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.candyPink,
                            AppColors.candyRose,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.candyRose.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 42,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'NoteVault',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.candyRose,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? 'Welcome back' : 'Create your vault',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Sign in to your candy note vault'
                          : 'Join NoteVault and organize with Life Spaces',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    AuthForm(
                      key: ValueKey(
                        'auth-${_isLogin ? 'login' : 'register'}-$_registeredEmail',
                      ),
                      isLogin: _isLogin,
                      initialEmail: _registeredEmail,
                      onToggleMode:
                          _isLogin ? _switchToRegister : () => _switchToLogin(),
                      onRegisterSuccess: (email) => _switchToLogin(email: email),
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
