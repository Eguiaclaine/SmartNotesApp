import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/auth_form.dart';

/// NoteVault entry — brand-led vault access (not a generic centered lock card).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  String? _registeredEmail;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

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
    final wide = MediaQuery.sizeOf(context).width >= 860;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthAtmosphere()),
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Positioned(
                top: -40 + (12 * _pulse.value),
                right: -30,
                child: child!,
              );
            },
            child: const _FloatingNotes(count: 3),
          ),
          SafeArea(
            child: wide
                ? Row(
                    children: [
                      Expanded(flex: 5, child: _BrandPanel(isLogin: _isLogin)),
                      Expanded(
                        flex: 6,
                        child: _AuthPanel(
                          isLogin: _isLogin,
                          registeredEmail: _registeredEmail,
                          onLoginTab: () => _switchToLogin(),
                          onJoinTab: _switchToRegister,
                          onRegisterSuccess: (email) => _switchToLogin(email: email),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    padding: pagePadding(context).copyWith(top: 12, bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BrandPanel(isLogin: _isLogin, compact: true),
                        const SizedBox(height: 20),
                        _AuthPanel(
                          isLogin: _isLogin,
                          registeredEmail: _registeredEmail,
                          onLoginTab: () => _switchToLogin(),
                          onJoinTab: _switchToRegister,
                          onRegisterSuccess: (email) => _switchToLogin(email: email),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Candy notes · Life Spaces · your private vault',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AuthAtmosphere extends StatelessWidget {
  const _AuthAtmosphere();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB8D4),
            AppColors.candyBlush,
            AppColors.lightBackground,
            const Color(0xFFFFF0F6),
          ],
          stops: const [0.0, 0.35, 0.72, 1.0],
        ),
      ),
      child: CustomPaint(painter: _SoftBurstPainter()),
    );
  }
}

class _SoftBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = AppColors.candyRose.withValues(alpha: 0.08);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.22), 120, paint);
    paint.color = AppColors.candyPink.withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.7), 160, paint);
    paint.color = AppColors.candyDeep.withValues(alpha: 0.05);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.95),
        width: size.width * 0.9,
        height: 140,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FloatingNotes extends StatelessWidget {
  const _FloatingNotes({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 160,
      child: Stack(
        children: List.generate(count, (index) {
          final angle = (-12.0 + index * 10) * math.pi / 180;
          return Positioned(
            left: 18.0 + index * 14,
            top: 20.0 + index * 10,
            child: Transform.rotate(
              angle: angle,
              child: Container(
                width: 88,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.85),
                      AppColors.candyBlush.withValues(alpha: 0.9),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.candyRose.withValues(alpha: 0.22),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.candyRose.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 8,
                      width: 48 - index * 6,
                      decoration: BoxDecoration(
                        color: AppColors.candyRose.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      3,
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          height: 5,
                          width: 54 - line * 8.0,
                          decoration: BoxDecoration(
                            color: AppColors.candyPink.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.isLogin, this.compact = false});

  final bool isLogin;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 8 : 36, compact ? 8 : 40, compact ? 8 : 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: compact ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.candyPink, AppColors.candyDeep],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'NOTEVAULT',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 3.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.candyDeep,
                    ),
              ),
            ],
          ),
          SizedBox(height: compact ? 14 : 28),
          Text(
            'NoteVault',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.candyRose,
                  height: 1.05,
                  fontSize: compact ? 42 : 56,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            isLogin ? 'Open your candy vault again.' : 'Start your own note vault today.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.softInk,
                  fontSize: compact ? 22 : 28,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            isLogin
                ? 'Sign in to keep writing, archive, and Life Spaces in sync.'
                : 'A private place for thoughts — no complex password format needed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
          ),
          if (!compact) ...[
            const SizedBox(height: 36),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _BrandChip(label: 'Life Spaces'),
                _BrandChip(label: 'Archive vault'),
                _BrandChip(label: 'Candy tags'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.candyRose.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.candyDeep,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.isLogin,
    required this.registeredEmail,
    required this.onLoginTab,
    required this.onJoinTab,
    required this.onRegisterSuccess,
  });

  final bool isLogin;
  final String? registeredEmail;
  final VoidCallback onLoginTab;
  final VoidCallback onJoinTab;
  final void Function(String email) onRegisterSuccess;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(36),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: [
              BoxShadow(
                color: AppColors.candyRose.withValues(alpha: 0.16),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.candyBlush.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeTab(
                        label: 'Sign in',
                        selected: isLogin,
                        onTap: onLoginTab,
                      ),
                    ),
                    Expanded(
                      child: _ModeTab(
                        label: 'Join',
                        selected: !isLogin,
                        onTap: onJoinTab,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isLogin ? 'Welcome back' : 'Create your access',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                isLogin
                    ? 'Use your NoteVault email to continue'
                    : 'Just a name, email, and password (6+ characters)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 18),
              AuthForm(
                key: ValueKey(
                  'auth-${isLogin ? 'login' : 'register'}-$registeredEmail',
                ),
                isLogin: isLogin,
                initialEmail: registeredEmail,
                showModeToggle: false,
                onToggleMode: isLogin ? onJoinTab : onLoginTab,
                onRegisterSuccess: onRegisterSuccess,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.candyRose.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? AppColors.candyDeep : AppColors.softInk.withValues(alpha: 0.55),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
