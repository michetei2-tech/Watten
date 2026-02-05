import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

class ScoreController {
  final int maxPoints;
  final int totalRounds;
  final int gamesPerRound;
  final bool gschneidertDoppelt;

  late String team1;
  late String team2;

  int currentRound = 1;
  int currentGame = 0;
  int? table;

  List<List<GameState>> allRounds = [];
  late List<GameState> games;

  ScoreController({
    required this.maxPoints,
    required this.totalRounds,
    required this.gamesPerRound,
    required this.gschneidertDoppelt,
    this.team1 = "",
    this.team2 = "",
  }) {
    games = List.generate(gamesPerRound, (_) => GameState());
  }

  GameState get game => games[currentGame];

  // ------------------------------------------------------------
  // SPIEL BEENDET?
  // ------------------------------------------------------------
  bool get isGameFinished {
    final lastRoundReached = currentRound == totalRounds;
    final lastGameReached = currentGame == gamesPerRound - 1;
    final lastGameFinished = game.p1 >= maxPoints || game.p2 >= maxPoints;

    return lastRoundReached && lastGameReached && lastGameFinished;
  }

  bool get isFinished => game.p1 >= maxPoints || game.p2 >= maxPoints;

  // ------------------------------------------------------------
  // SCORE ADD
  // ------------------------------------------------------------
  void addScore(int player, int points) {
    if (isFinished) return;

    if (player == 1) {
      final before = game.p1;
      game.p1 += points;

      if (game.p1 > maxPoints) {
        final applied = maxPoints - before;
        game.p1 = maxPoints;

        if (applied > 0) {
          game.p1Points.add(applied);
          game.history.add(applied);
        }

        _applyGschneidertDoppelt();
        _autoSave();
        return;
      }

      game.p1Points.add(points);
      game.history.add(points);
    } else {
      final before = game.p2;
      game.p2 += points;

      if (game.p2 > maxPoints) {
        final applied = maxPoints - before;
        game.p2 = maxPoints;

        if (applied > 0) {
          game.p2Points.add(applied);
          game.history.add(-applied);
        }

        _applyGschneidertDoppelt();
        _autoSave();
        return;
      }

      game.p2Points.add(points);
      game.history.add(-points);
    }

    if (isFinished) {
      _applyGschneidertDoppelt();
      game.p1Tense = false;
      game.p2Tense = false;
    }

    _autoSave();
  }

  // ------------------------------------------------------------
  // GSCHNEIDERT DOPPELT
  // ------------------------------------------------------------
  void _applyGschneidertDoppelt() {
    if (!gschneidertDoppelt) return;

    final p1 = game.p1;
    final p2 = game.p2;

    if (p1 == maxPoints && p2 == 0) game.gschneidertWinner = 1;
    if (p2 == maxPoints && p1 == 0) game.gschneidertWinner = 2;
  }

  // ------------------------------------------------------------
  // UNDO
  // ------------------------------------------------------------
  void undo() {
    if (game.history.isEmpty) return;

    final last = game.history.removeLast();

    if (last > 0) {
      game.p1 -= last;
      if (game.p1Points.isNotEmpty) game.p1Points.removeLast();
    } else {
      game.p2 -= last.abs();
      if (game.p2Points.isNotEmpty) game.p2Points.removeLast();
    }

    game.gschneidertWinner = 0;

    _autoSave();
  }

  // ------------------------------------------------------------
  // TENSE
  // ------------------------------------------------------------
  void toggleTense(int player) {
    if (player == 1) {
      game.p1Tense = !game.p1Tense;
    } else {
      game.p2Tense = !game.p2Tense;
    }
    _autoSave();
  }

  // ------------------------------------------------------------
  // SPIELE NAVIGATION
  // ------------------------------------------------------------
  bool get canNext => currentGame < gamesPerRound - 1;
  bool get canPrev => currentGame > 0;

  void nextGame() {
    if (canNext) currentGame++;
    _autoSave();
  }

  void prevGame() {
    if (canPrev) currentGame--;
    _autoSave();
  }

  // ------------------------------------------------------------
  // RUNDEN NAVIGATION
  // ------------------------------------------------------------
  bool hasPrevRound(int viewRound) => viewRound < allRounds.length;
  bool hasNextRound(int viewRound) => viewRound > 0;

  List<GameState> getRoundGames(int viewRound) {
    if (viewRound == 0) return games;
    return allRounds[viewRound - 1];
  }

  // ------------------------------------------------------------
  // NEUE RUNDE
  // ------------------------------------------------------------
  void newRound() {
    allRounds.add(games);
    games = List.generate(gamesPerRound, (_) => GameState());
    currentGame = 0;
    currentRound++;
    table = null;
    _autoSave();
  }

  // ------------------------------------------------------------
  // JSON EXPORT
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      "team1": team1,
      "team2": team2,
      "maxPoints": maxPoints,
      "totalRounds": totalRounds,
      "gamesPerRound": gamesPerRound,
      "gschneidertDoppelt": gschneidertDoppelt,
      "currentRound": currentRound,
      "currentGame": currentGame,
      "table": table,
      "games": games.map((g) => g.toJson()).toList(),
      "allRounds": allRounds
          .map((round) => round.map((g) => g.toJson()).toList())
          .toList(),
    };
  }

  // ------------------------------------------------------------
  // JSON IMPORT (STATIC)
  // ------------------------------------------------------------
  static ScoreController fromJson(Map<String, dynamic> json) {
    final c = ScoreController(
      maxPoints: json["maxPoints"],
      totalRounds: json["totalRounds"],
      gamesPerRound: json["gamesPerRound"],
      gschneidertDoppelt: json["gschneidertDoppelt"],
      team1: json["team1"],
      team2: json["team2"],
    );

    c.currentRound = json["currentRound"];
    c.currentGame = json["currentGame"];
    c.table = json["table"];

    c.games = (json["games"] as List)
        .map((g) => GameState.fromJson(g))
        .toList();

    c.allRounds = (json["allRounds"] as List)
        .map((round) =>
            (round as List).map((g) => GameState.fromJson(g)).toList())
        .toList();

    return c;
  }

  // ------------------------------------------------------------
  // JSON IMPORT (INSTANCE) — für Zwei-Geräte-Modus
  // ------------------------------------------------------------
  void loadFromJson(Map<String, dynamic> json) {
    team1 = json["team1"] ?? team1;
    team2 = json["team2"] ?? team2;

    currentRound = json["currentRound"] ?? currentRound;
    currentGame = json["currentGame"] ?? currentGame;
    table = json["table"];

    if (json.containsKey("games")) {
      games = (json["games"] as List)
          .map((g) => GameState.fromJson(Map<String, dynamic>.from(g)))
          .toList();
    }

    if (json.containsKey("allRounds")) {
      allRounds = (json["allRounds"] as List)
          .map((round) => (round as List)
              .map((g) => GameState.fromJson(Map<String, dynamic>.from(g)))
              .toList())
          .toList();
    }
  }

  // ------------------------------------------------------------
  // SPEICHERN / LADEN
  // ------------------------------------------------------------
  Future<void> saveLastGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("lastGame", jsonEncode(toJson()));
  }

  Future<void> clearLastGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("lastGame");
  }

  static Future<ScoreController?> loadLastGame() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("lastGame");
    if (jsonString == null) return null;
    return ScoreController.fromJson(jsonDecode(jsonString));
  }

  // ------------------------------------------------------------
  // AUTO-SAVE
  // ------------------------------------------------------------
  void _autoSave() {
    if (isGameFinished) {
      clearLastGame();
    } else {
      saveLastGame();
    }
  }
}
