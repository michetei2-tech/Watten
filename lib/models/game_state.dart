class GameState {
  int p1 = 0;
  int p2 = 0;

  List<int> p1Points = [];
  List<int> p2Points = [];

  List<int> history = [];

  bool p1Tense = false;
  bool p2Tense = false;

  /// 0 = keiner, 1 = Team 1, 2 = Team 2
  int gschneidertWinner = 0;

  GameState();

  Map<String, dynamic> toJson() {
    return {
      "p1": p1,
      "p2": p2,
      "p1Points": p1Points,
      "p2Points": p2Points,
      "history": history,
      "p1Tense": p1Tense,
      "p2Tense": p2Tense,
      "gschneidertWinner": gschneidertWinner,
    };
  }

  static GameState fromJson(Map<String, dynamic> json) {
    final g = GameState();

    g.p1 = json["p1"];
    g.p2 = json["p2"];

    g.p1Points = List<int>.from(json["p1Points"]);
    g.p2Points = List<int>.from(json["p2Points"]);

    g.history = List<int>.from(json["history"]);

    g.p1Tense = json["p1Tense"];
    g.p2Tense = json["p2Tense"];

    g.gschneidertWinner = json["gschneidertWinner"] ?? 0;

    return g;
  }
}
