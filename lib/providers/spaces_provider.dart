import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/space.dart';
import '../services/spaces_service.dart';
import '../services/storage_service.dart';

class SpacesProvider extends ChangeNotifier {
  SpacesProvider(this.userId, {this.supabaseReady = true}) {
    // Defer load so we never notify during widget/provider build.
    scheduleMicrotask(() async {
      if (_disposed) return;
      await _loadSpaces();
      if (_disposed || !supabaseReady) return;
      _subscribeRealtime();
    });
  }

  final String userId;
  final bool supabaseReady;
  final SpacesService _spacesService = SpacesService();
  final StorageService _storageService = StorageService();

  RealtimeChannel? _channel;
  List<Space> _spaces = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _disposed = false;

  List<Space> get spaces {
    final sorted = [..._spaces]
      ..sort((a, b) {
        if (a.isFocus != b.isFocus) return a.isFocus ? -1 : 1;
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return a.createdAt.compareTo(b.createdAt);
      });
    return sorted;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Space? get focusSpace {
    for (final space in _spaces) {
      if (space.isFocus) return space;
    }
    return null;
  }

  Space? spaceById(String? id) {
    if (id == null) return null;
    for (final space in _spaces) {
      if (space.id == id) return space;
    }
    return null;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> reload() async {
    await _loadSpaces();
    if (_disposed || !supabaseReady) return;
    _spacesService.unsubscribe(_channel);
    _subscribeRealtime();
  }

  void _subscribeRealtime() {
    _channel = _spacesService.subscribeToSpaces(
      userId: userId,
      onChanged: (spaces) async {
        if (_disposed) return;
        _spaces = spaces;
        await _storageService.saveSpaces(_spaces);
        _safeNotify();
      },
      onStatus: (status, error) {
        if (error != null && kDebugMode) {
          debugPrint('Spaces realtime error: $error');
        }
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _spacesService.unsubscribe(_channel);
    super.dispose();
  }

  Future<void> _loadSpaces() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotify();
    try {
      final cached = await _storageService.loadSpaces();
      if (_disposed) return;
      _spaces = cached.where((space) => space.userId == userId).toList();
      _safeNotify();

      if (supabaseReady) {
        _spaces = await _spacesService
            .fetchSpaces(userId)
            .timeout(const Duration(seconds: 15));
        if (_disposed) return;
        await _storageService.saveSpaces(_spaces);
      }
    } on TimeoutException {
      _errorMessage =
          'Life Spaces took too long to load. Check your connection, then pull to refresh.';
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<bool> addSpace({
    required String name,
    required String emoji,
    required String colorHex,
    String? motto,
    SpaceMood mood = SpaceMood.focus,
    int weeklyGoal = 5,
    bool isFocus = false,
  }) async {
    final space = Space(
      id: const Uuid().v4(),
      userId: userId,
      name: name.trim(),
      emoji: emoji,
      colorHex: colorHex,
      motto: motto?.trim().isEmpty == true ? null : motto?.trim(),
      mood: mood,
      weeklyGoal: weeklyGoal.clamp(1, 50),
      isFocus: isFocus,
      sortOrder: _spaces.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      var nextSpaces = [..._spaces, space];
      if (isFocus) {
        nextSpaces = nextSpaces
            .map((item) => item.id == space.id ? item : item.copyWith(isFocus: false))
            .toList();
      }

      if (supabaseReady) {
        if (isFocus) {
          for (final item in _spaces.where((s) => s.isFocus)) {
            await _spacesService.updateSpace(item.copyWith(isFocus: false));
          }
        }
        await _spacesService
            .createSpace(space)
            .timeout(const Duration(seconds: 15));
      }

      if (_disposed) return false;
      _spaces = nextSpaces;
      await _storageService.saveSpaces(_spaces);
      _errorMessage = null;
      _safeNotify();
      return true;
    } on TimeoutException {
      _errorMessage = 'Saving Life Space timed out. Try again.';
      _safeNotify();
      return false;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _safeNotify();
      return false;
    }
  }

  Future<bool> addFromTemplate(SpaceTemplate template) {
    return addSpace(
      name: template.name,
      emoji: template.emoji,
      colorHex: template.colorHex,
      motto: template.motto,
      mood: template.mood,
      weeklyGoal: template.weeklyGoal,
    );
  }

  Future<bool> updateSpace(Space space) async {
    try {
      final updated = space.copyWith(updatedAt: DateTime.now());
      var nextSpaces = _spaces.map((item) => item.id == updated.id ? updated : item).toList();

      if (updated.isFocus) {
        nextSpaces = nextSpaces
            .map((item) => item.id == updated.id ? item : item.copyWith(isFocus: false))
            .toList();
      }

      if (supabaseReady) {
        if (updated.isFocus) {
          for (final item in _spaces.where((s) => s.isFocus && s.id != updated.id)) {
            await _spacesService.updateSpace(item.copyWith(isFocus: false));
          }
        }
        await _spacesService
            .updateSpace(updated)
            .timeout(const Duration(seconds: 15));
      }

      if (_disposed) return false;
      _spaces = nextSpaces;
      await _storageService.saveSpaces(_spaces);
      _errorMessage = null;
      _safeNotify();
      return true;
    } on TimeoutException {
      _errorMessage = 'Updating Life Space timed out. Try again.';
      _safeNotify();
      return false;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _safeNotify();
      return false;
    }
  }

  Future<bool> setFocusSpace(String id) async {
    final target = spaceById(id);
    if (target == null) return false;
    return updateSpace(target.copyWith(isFocus: true));
  }

  Future<bool> clearFocusSpace(String id) async {
    final target = spaceById(id);
    if (target == null) return false;
    return updateSpace(target.copyWith(isFocus: false));
  }

  Future<bool> deleteSpace(String id) async {
    try {
      if (supabaseReady) {
        await _spacesService
            .deleteSpace(id)
            .timeout(const Duration(seconds: 15));
      }
      if (_disposed) return false;
      _spaces.removeWhere((space) => space.id == id);
      await _storageService.saveSpaces(_spaces);
      _errorMessage = null;
      _safeNotify();
      return true;
    } on TimeoutException {
      _errorMessage = 'Deleting Life Space timed out. Try again.';
      _safeNotify();
      return false;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _safeNotify();
      return false;
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if ((message.contains('relation') && message.contains('spaces')) ||
        message.contains('Could not find the table') ||
        message.contains('PGRST205')) {
      return 'Life Spaces table missing. Run supabase/sql/14_life_spaces_align.sql in Supabase SQL Editor.';
    }
    if (message.contains('motto') ||
        message.contains('weekly_goal') ||
        message.contains('is_focus') ||
        message.contains('sort_order') ||
        message.contains('mood') ||
        message.contains('column') ||
        message.contains('PGRST204') ||
        message.contains('schema cache')) {
      return 'Life Spaces schema outdated. Run supabase/sql/14_life_spaces_align.sql in Supabase SQL Editor.';
    }
    if (message.contains('violates check constraint')) {
      return 'Check space name (1–40 chars), mood, and weekly goal (1–50).';
    }
    return message.replaceFirst('Exception: ', '');
  }
}
