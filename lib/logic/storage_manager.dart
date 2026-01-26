import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'score_controller.dart';

class SavedGame {
  final String name;
  final DateTime savedAt;
  final ScoreController controller;

  SavedGame({
    required this.name,
    required this.savedAt,
    required this.controller,
  });
}

class StorageManager {
  static const String _keySavedGames = "savedGamesV1";

  // Alle gespeicherten Spiele laden
  static Future<List<SavedGame>> loadAllGames() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySavedGames);
    if (raw == null) return [];

    final Map<String, dynamic> map = jsonDecode(raw);
    final List<SavedGame> result = [];

    map.forEach((name, value) {
      try {
        final decoded = jsonDecode(value);
        final savedAt = DateTime.parse(decoded["savedAt"]);
        final data = decoded["data"] as Map<String, dynamic>;
        final controller = ScoreController.fromJson(data);
        result.add(SavedGame(name: name, savedAt: savedAt, controller: controller));
      } catch (_) {
        // defekte Einträge ignorieren
      }
    });

    // Neueste oben
    result.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return result;
  }

  // Einzelnes Spiel speichern (überschreibt bei gleichem Namen)
  static Future<void> saveGame(String name, ScoreController controller) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySavedGames);
    Map<String, dynamic> map = {};
    if (raw != null) {
      map = jsonDecode(raw);
    }

    final wrapper = {
      "savedAt": DateTime.now().toIso8601String(),
      "data": controller.toJson(),
    };

    map[name] = jsonEncode(wrapper);
    await prefs.setString(_keySavedGames, jsonEncode(map));
  }

  // Spiel löschen
  static Future<void> deleteGame(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySavedGames);
    if (raw == null) return;

    final Map<String, dynamic> map = jsonDecode(raw);
    map.remove(name);
    await prefs.setString(_keySavedGames, jsonEncode(map));
  }

  // Prüfen, ob ein Name bereits existiert
  static Future<bool> exists(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySavedGames);
    if (raw == null) return false;
    final Map<String, dynamic> map = jsonDecode(raw);
    return map.containsKey(name);
  }
}
