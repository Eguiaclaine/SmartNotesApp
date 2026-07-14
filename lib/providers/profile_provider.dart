import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../utils/validation_utils.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this.userId, {this.supabaseReady = true}) {
    loadProfile();
    if (supabaseReady) {
      _subscribeRealtime();
    }
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

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get isRealtimeConnected => _isRealtimeConnected;

  void _subscribeRealtime() {
    _channel = _profileService.subscribeToProfile(
      userId: userId,
      onChanged: (profile) {
        _profile = profile;
        notifyListeners();
      },
      onStatus: (status, error) {
        _isRealtimeConnected = status == RealtimeSubscribeStatus.subscribed;
        if (error != null && kDebugMode) {
          debugPrint('Profile realtime error: $error');
        }
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _profileService.unsubscribe(_channel);
    super.dispose();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _profile = await _profileService.fetchProfile(userId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(String displayName) async {
    final sanitized = SanitizationUtils.sanitizeText(displayName, maxLength: 50);
    final validation = ValidationUtils.validateFullName(sanitized);
    if (validation != null) {
      _errorMessage = validation;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
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
      notifyListeners();
    }
  }

  Future<bool> uploadAvatar(Uint8List bytes, String fileName) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
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
      notifyListeners();
    }
  }
}
