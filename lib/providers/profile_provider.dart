import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../utils/validation_utils.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this.userId, {this.supabaseReady = true}) {
    scheduleMicrotask(() async {
      if (_disposed) return;
      await loadProfile();
      if (_disposed || !supabaseReady) return;
      _subscribeRealtime();
    });
  }

  final String userId;
  final bool supabaseReady;
  final ProfileService _profileService = ProfileService();

  RealtimeChannel? _channel;
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  bool _isRealtimeConnected = false;
  bool _disposed = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get isRealtimeConnected => _isRealtimeConnected;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _subscribeRealtime() {
    _channel = _profileService.subscribeToProfile(
      userId: userId,
      onChanged: (profile) {
        if (_disposed) return;
        _profile = profile;
        _safeNotify();
      },
      onStatus: (status, error) {
        if (_disposed) return;
        _isRealtimeConnected = status == RealtimeSubscribeStatus.subscribed;
        if (error != null && kDebugMode) {
          debugPrint('Profile realtime error: $error');
        }
        _safeNotify();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _profileService.unsubscribe(_channel);
    super.dispose();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();
    try {
      _profile = await _profileService
          .fetchProfile(userId)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      _errorMessage = 'Profile took too long to load.';
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> saveProfile(String displayName) async {
    final sanitized = SanitizationUtils.sanitizeText(displayName, maxLength: 50);
    final validation = ValidationUtils.validateFullName(sanitized);
    if (validation != null) {
      _errorMessage = validation;
      _safeNotify();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _safeNotify();
    try {
      final current = _profile ??
          UserProfile(id: userId, email: null, displayName: sanitized);
      _profile = await _profileService.updateProfile(
        current.copyWith(displayName: sanitized),
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      _safeNotify();
    }
  }

  Future<bool> uploadAvatar(Uint8List bytes, String fileName) async {
    _isSaving = true;
    _errorMessage = null;
    _safeNotify();
    try {
      final url = await _profileService.uploadAvatar(userId, bytes, fileName);
      if (url == null) return false;
      final current = _profile ?? UserProfile(id: userId);
      _profile = await _profileService.updateProfile(
        current.copyWith(avatarUrl: url),
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      _safeNotify();
    }
  }
}
