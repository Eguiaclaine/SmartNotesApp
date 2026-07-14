import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
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
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: pagePadding(context),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        size: 64,
                        color: scheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isLogin ? 'Welcome back' : 'Join Smart Notes',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? 'Sign in to Smart Notes' : 'Create Account',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      AuthForm(
                        key: ValueKey('auth-${_isLogin ? 'login' : 'register'}-$_registeredEmail'),
                        isLogin: _isLogin,
                        initialEmail: _registeredEmail,
                        onToggleMode: _isLogin ? _switchToRegister : () => _switchToLogin(),
                        onRegisterSuccess: (email) => _switchToLogin(email: email),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
                tooltip: themeProvider.isDark ? 'Light mode' : 'Dark mode',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
