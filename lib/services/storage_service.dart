import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';
import '../models/space.dart';

class StorageService {
  static const _notesKey = 'cached_notes';
  static const _spacesKey = 'cached_spaces';

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

  Future<List<Space>> loadSpaces() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_spacesKey) ?? <String>[];
    return raw
        .map((item) => Space.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSpaces(List<Space> spaces) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = spaces.map((space) => jsonEncode(space.toJson())).toList();
    await prefs.setStringList(_spacesKey, raw);
  }
}
