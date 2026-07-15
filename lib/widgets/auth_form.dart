import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validation_utils.dart';
import '../widgets/candy_ui.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onToggleMode,
    this.onRegisterSuccess,
    this.initialEmail,
    this.showModeToggle = true,
  });

  final bool isLogin;
  final VoidCallback onToggleMode;
  final void Function(String email)? onRegisterSuccess;
  final String? initialEmail;
  final bool showModeToggle;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void didUpdateWidget(AuthForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialEmail != null &&
        widget.initialEmail != oldWidget.initialEmail &&
        widget.isLogin) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isLogin && authProvider.successMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.candyBlush.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: scheme.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authProvider.successMessage!,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (authProvider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: scheme.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(authProvider.errorMessage!)),
                ],
              ),
            ),
          ],
          if (!widget.isLogin) ...[
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              textInputAction: TextInputAction.next,
              validator: ValidationUtils.validateFullName,
            ),
            const SizedBox(height: 14),
          ],
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: ValidationUtils.validateEmail,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: widget.isLogin ? null : 'At least 6 characters',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) => ValidationUtils.validatePassword(
              value,
              forSignUp: !widget.isLogin,
            ),
          ),
          if (!widget.isLogin) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_person_outlined),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              obscureText: _obscureConfirm,
              validator: (value) => ValidationUtils.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
            ),
          ],
          const SizedBox(height: 24),
          CandyButton(
            label: widget.isLogin ? 'Enter NoteVault' : 'Create my vault',
            icon: widget.isLogin ? Icons.arrow_forward_rounded : Icons.auto_awesome_rounded,
            isLoading: authProvider.isLoading,
            onPressed: authProvider.isLoading ? null : _submit,
          ),
          if (widget.showModeToggle) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onToggleMode,
              child: Text(
                widget.isLogin
                    ? 'New here? Create an account'
                    : 'Already have an account? Sign in',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final email = SanitizationUtils.sanitizeEmail(_emailController.text);
    final password = _passwordController.text;

    if (widget.isLogin) {
      await authProvider.signIn(email, password);
    } else {
      final registered = await authProvider.signUp(
        fullName: SanitizationUtils.sanitizeText(_fullNameController.text, maxLength: 50),
        email: email,
        password: password,
      );
      if (registered && mounted) {
        widget.onRegisterSuccess?.call(email);
      }
    }
  }
}
