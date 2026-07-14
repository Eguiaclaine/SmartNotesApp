import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/validation_utils.dart';
import '../widgets/password_requirements.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onToggleMode,
    this.onRegisterSuccess,
    this.initialEmail,
  });

  final bool isLogin;
  final VoidCallback onToggleMode;
  final void Function(String email)? onRegisterSuccess;
  final String? initialEmail;

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
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: scheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.successMessage!,
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (authProvider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(authProvider.errorMessage!),
            ),
          ],
          if (!widget.isLogin) ...[
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              textInputAction: TextInputAction.next,
              validator: ValidationUtils.validateFullName,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: ValidationUtils.validateEmail,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
              ),
            ),
            obscureText: _obscurePassword,
            onChanged: (_) => setState(() {}),
            validator: (value) => ValidationUtils.validatePassword(
              value,
              forSignUp: !widget.isLogin,
            ),
          ),
          if (!widget.isLogin) ...[
            const SizedBox(height: 12),
            PasswordRequirementsList(password: _passwordController.text),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
          const SizedBox(height: 20),
          FilledButton(
            onPressed: authProvider.isLoading ? null : _submit,
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(widget.isLogin ? 'Sign In' : 'Register'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onToggleMode,
            child: Text(
              widget.isLogin
                  ? 'Create an account'
                  : 'Already have an account? Sign in',
            ),
          ),
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
