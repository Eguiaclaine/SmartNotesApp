import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/space.dart';
import '../services/spaces_service.dart';
import '../services/storage_service.dart';

class SpacesProvider extends ChangeNotifier {
  SpacesProvider(this.userId, {this.supabaseReady = true}) {
    _loadSpaces();
    if (supabaseReady) {
      _subscribeRealtime();
    }
  }

  final String userId;
  final bool supabaseReady;
  final SpacesService _spacesService = SpacesService();
  final StorageService _storageService = StorageService();

  RealtimeChannel? _channel;
  List<Space> _spaces = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Space> get spaces => _spaces;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Space? spaceById(String? id) {
    if (id == null) return null;
    for (final space in _spaces) {
      if (space.id == id) return space;
    }
    return null;
  }

  Future<void> reload() async {
    await _loadSpaces();
    if (supabaseReady) {
      _spacesService.unsubscribe(_channel);
      _subscribeRealtime();
    }
  }

  void _subscribeRealtime() {
    _channel = _spacesService.subscribeToSpaces(
      userId: userId,
      onChanged: (spaces) async {
        _spaces = spaces;
        await _storageService.saveSpaces(_spaces);
        notifyListeners();
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
    _spacesService.unsubscribe(_channel);
    super.dispose();
  }

  Future<void> _loadSpaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final cached = await _storageService.loadSpaces();
      _spaces = cached.where((space) => space.userId == userId).toList();
      notifyListeners();

      if (supabaseReady) {
        _spaces = await _spacesService.fetchSpaces(userId);
        await _storageService.saveSpaces(_spaces);
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSpace({
    required String name,
    required String emoji,
    required String colorHex,
  }) async {
    final space = Space(
      id: const Uuid().v4(),
      userId: userId,
      name: name.trim(),
      emoji: emoji,
      colorHex: colorHex,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (supabaseReady) {
        await _spacesService.createSpace(space);
      }
      _spaces = [..._spaces, space];
      await _storageService.saveSpaces(_spaces);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSpace(Space space) async {
    try {
      final updated = space.copyWith(updatedAt: DateTime.now());
      if (supabaseReady) {
        await _spacesService.updateSpace(updated);
      }
      _spaces = _spaces.map((item) => item.id == updated.id ? updated : item).toList();
      await _storageService.saveSpaces(_spaces);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSpace(String id) async {
    try {
      if (supabaseReady) {
        await _spacesService.deleteSpace(id);
      }
      _spaces.removeWhere((space) => space.id == id);
      await _storageService.saveSpaces(_spaces);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
