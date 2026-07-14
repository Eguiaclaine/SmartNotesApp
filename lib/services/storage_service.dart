import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class StorageService {
  static const _notesKey = 'cached_notes';
  static const _themeKey = 'theme_mode_dark';

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_notesKey) ?? <String>[];
    return raw
        .map((item) => Note.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(_notesKey, raw);
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
