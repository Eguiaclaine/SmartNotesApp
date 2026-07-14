import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';



import '../services/auth_service.dart';



enum AuthLoadingPhase { none, signingIn, signingUp, signingOut }



class AuthProvider extends ChangeNotifier {

  AuthProvider() {

    _user = _authService.currentUser;

    _authService.authStateChanges.listen((state) {

      _user = state.session?.user;

      notifyListeners();

    });

  }



  final AuthService _authService = AuthService();

  User? _user;

  bool _isLoading = false;

  AuthLoadingPhase _loadingPhase = AuthLoadingPhase.none;

  String? _errorMessage;

  String? _successMessage;



  User? get user => _user;

  bool get isLoading => _isLoading;

  AuthLoadingPhase get loadingPhase => _loadingPhase;

  bool get isSigningOut => _loadingPhase == AuthLoadingPhase.signingOut;

  bool get isTransitioning => _loadingPhase != AuthLoadingPhase.none;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;



  String get loadingMessage => switch (_loadingPhase) {

        AuthLoadingPhase.signingOut => 'Signing you out safely...',

        AuthLoadingPhase.signingUp => 'Creating your account...',

        AuthLoadingPhase.signingIn => 'Signing you in...',

        AuthLoadingPhase.none => 'Loading NoteVault...',

      };



  void clearMessages() {

    _errorMessage = null;

    _successMessage = null;

    notifyListeners();

  }



  Future<bool> signIn(String email, String password) async {

    _beginLoading(AuthLoadingPhase.signingIn);

    try {

      await _authService.signIn(email.trim(), password);

      await _holdTransition();

      return true;

    } catch (error) {

      _errorMessage = _friendlyError(error);

      return false;

    } finally {

      _endLoading();

    }

  }



  /// Registers a new user, then signs out so they land on login (not dashboard).

  Future<bool> signUp({

    required String fullName,

    required String email,

    required String password,

  }) async {

    _beginLoading(AuthLoadingPhase.signingUp);

    try {

      await _authService.signUp(

        email: email.trim(),

        password: password,

        fullName: fullName.trim(),

      );



      _loadingPhase = AuthLoadingPhase.signingOut;

      notifyListeners();



      await _authService.signOut();

      _user = null;

      _successMessage =

          'Account created successfully. Sign in when you are ready.';

      await _holdTransition();

      return true;

    } catch (error) {

      _errorMessage = _friendlyError(error);

      return false;

    } finally {

      _endLoading();

    }

  }



  Future<void> signOut() async {

    _beginLoading(AuthLoadingPhase.signingOut);

    try {

      await _authService.signOut();

      _user = null;

      _successMessage = null;

      await _holdTransition();

    } finally {

      _endLoading();

    }

  }



  void _beginLoading(AuthLoadingPhase phase) {

    _isLoading = true;

    _loadingPhase = phase;

    _errorMessage = null;

    if (phase != AuthLoadingPhase.signingUp) {

      _successMessage = null;

    }

    notifyListeners();

  }



  void _endLoading() {

    _isLoading = false;

    _loadingPhase = AuthLoadingPhase.none;

    notifyListeners();

  }



  Future<void> _holdTransition() async {

    await Future<void>.delayed(const Duration(milliseconds: 700));

  }



  String _friendlyError(Object error) {

    if (error is AuthException) {

      return switch (error.code) {

        'signup_disabled' =>

          'Sign up is disabled. In Supabase Dashboard go to Authentication → Providers → Email and enable sign ups.',

        'email_address_invalid' => 'Enter a valid email address.',

        'weak_password' => 'Password is too weak. Use at least 8 characters with mixed case, numbers, and symbols.',

        'user_already_exists' => 'An account with this email already exists.',

        'invalid_credentials' => 'Invalid email or password.',

        _ => error.message,

      };

    }



    final message = error.toString();

    if (message.contains('Invalid login credentials')) {

      return 'Invalid email or password.';

    }

    if (message.contains('User already registered')) {

      return 'An account with this email already exists.';

    }

    if (message.contains('signup_disabled')) {

      return 'Sign up is disabled. Enable Email sign ups in Supabase Dashboard → Authentication → Providers → Email.';

    }

    return message.replaceFirst('Exception: ', '').replaceFirst('AuthApiException(message: ', '');

  }

}


