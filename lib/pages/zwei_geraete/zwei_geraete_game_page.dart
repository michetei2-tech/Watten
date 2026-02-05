import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../logic/score_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/player_half.dart';
import '../scoreboard_page.dart';

class ZweiGeraeteGamePage extends StatefulWidget {
  final String sessionId;
  final String team1;
  final String team2;
  final int maxPoints;
  final int totalRounds;
  final int gamesPerRound;
  final bool gschneidertDoppelt;
  final bool isCoordinator;

  const ZweiGeraeteGamePage({
    super.key,
    required this.sessionId,
    required this.team1,
    required this.team2,
    required this.maxPoints,
    required this.totalRounds,
    required this.gamesPerRound,
    required this.gschneidertDoppelt,
    required this.isCoordinator,
  });

  @override
  State<ZweiGeraeteGamePage> createState() => _ZweiGeraeteGamePageState();
}

class _ZweiGeraeteGamePageState extends State<ZweiGeraeteGamePage> {
  late DatabaseReference sessionRef;
  late ScoreController controller;

  bool navigated = false;

  @override
  void initState() {
    super.initState();

    controller = ScoreController(
      maxPoints: widget.maxPoints,
      totalRounds: widget.totalRounds,
      gamesPerRound: widget.gamesPerRound,
      gschneidertDoppelt: widget.gschneidertDoppelt,
      team1: widget.team1,
      team2: widget.team2,
    );

    sessionRef = FirebaseDatabase.instance.ref("sessions/${widget.sessionId}");

    _listenToSession();
  }

  // ------------------------------------------------------------
  // SESSION LISTENER
  // ------------------------------------------------------------
  void _listenToSession() {
    sessionRef.onValue.listen((event) {
      if (!mounted || navigated) return;

      if (!event.snapshot.exists) {
        _fallbackToSingleDevice("Die Session wurde beendet.");
        return;
      }

      final map = Map<String, dynamic>.from(event.snapshot.value as Map);

      final coordinatorConnected = map["coordinatorConnected"] ?? false;
      final playerConnected = map["playerConnected"] ?? false;

      // Koordinator weg → Spieler übernimmt
      if (!widget.isCoordinator && !coordinatorConnected) {
        _fallbackToSingleDevice("Der Koordinator hat die Verbindung verloren.");
        return;
      }

      // Spieler weg → Koordinator übernimmt
      if (widget.isCoordinator && !playerConnected) {
        _fallbackToSingleDevice("Der Mitspieler hat die Verbindung verloren.");
        return;
      }

      // ScoreController synchronisieren
      if (map.containsKey("controller")) {
        controller.loadFromJson(
          Map<String, dynamic>.from(map["controller"]),
        );
        if (mounted) setState(() {});
      }
    });
  }

  // ------------------------------------------------------------
  // Fallback in Ein-Geräte-Modus
  // ------------------------------------------------------------
  void _fallbackToSingleDevice(String reason) async {
    if (navigated) return;
    navigated = true;

    await sessionRef.remove();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ScoreboardPage(
          isTournament: false,
          team1: widget.team1,
          team2: widget.team2,
          totalRounds: widget.totalRounds,
          maxPoints: widget.maxPoints,
          gamesPerRound: widget.gamesPerRound,
          gschneidertDoppelt: widget.gschneidertDoppelt,
          loadedController: controller,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Sync
  // ------------------------------------------------------------
  Future<void> _sync() async {
    await sessionRef.update({
      "controller": controller.toJson(),
    });
  }

  // ------------------------------------------------------------
  // Dispose → Session NICHT löschen!
  // ------------------------------------------------------------
  @override
  void dispose() {
    if (!widget.isCoordinator) {
      sessionRef.update({"playerConnected": false});
    }
    super.dispose();
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final games = controller.getRoundGames(0);
    final game = games[controller.currentGame];

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: RotatedBox(
                quarterTurns: 2,
                child: PlayerHalf(
                  player: 2,
                  game: game,
                  leftTeam: widget.team2,
                  rightTeam: widget.team1,
                  table: controller.table,
                  controller: controller,
                  onUndo: () {
                    controller.undo();
                    setState(() {});
                    _sync();
                  },
                  onToggleTense: () {
                    controller.toggleTense(2);
                    setState(() {});
                    _sync();
                  },
                  onPrevGame: () {
                    controller.prevGame();
                    setState(() {});
                    _sync();
                  },
                  onNextGame: () {
                    controller.nextGame();
                    setState(() {});
                    _sync();
                  },
                  onPickTable: (v) {
                    controller.table = v;
                    setState(() {});
                    _sync();
                  },
                  onAddScore: (v) {
                    controller.addScore(2, v);
                    setState(() {});
                    _sync();
                  },
                  canNext: controller.canNext,
                  canPrev: controller.canPrev,
                  currentGame: controller.currentGame,
                  viewRound: 0,
                  onPrevRound: () {},
                  onNextRound: () {},
                  onAuswertung: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScoreboardPage(
                          isTournament: false,
                          team1: widget.team1,
                          team2: widget.team2,
                          totalRounds: widget.totalRounds,
                          maxPoints: widget.maxPoints,
                          gamesPerRound: widget.gamesPerRound,
                          gschneidertDoppelt: widget.gschneidertDoppelt,
                          loadedController: controller,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: PlayerHalf(
                player: 1,
                game: game,
                leftTeam: widget.team1,
                rightTeam: widget.team2,
                table: controller.table,
                controller: controller,
                onUndo: () {
                  controller.undo();
                  setState(() {});
                  _sync();
                },
                onToggleTense: () {
                  controller.toggleTense(1);
                  setState(() {});
                  _sync();
                },
                onPrevGame: () {
                  controller.prevGame();
                  setState(() {});
                  _sync();
                },
                onNextGame: () {
                  controller.nextGame();
                  setState(() {});
                  _sync();
                },
                onPickTable: (v) {
                  controller.table = v;
                  setState(() {});
                  _sync();
                },
                onAddScore: (v) {
                  controller.addScore(1, v);
                  setState(() {});
                  _sync();
                },
                canNext: controller.canNext,
                canPrev: controller.canPrev,
                currentGame: controller.currentGame,
                viewRound: 0,
                onPrevRound: () {},
                onNextRound: () {},
                onAuswertung: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScoreboardPage(
                        isTournament: false,
                        team1: widget.team1,
                        team2: widget.team2,
                        totalRounds: widget.totalRounds,
                        maxPoints: widget.maxPoints,
                        gamesPerRound: widget.gamesPerRound,
                        gschneidertDoppelt: widget.gschneidertDoppelt,
                        loadedController: controller,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
