import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../logic/score_controller.dart';
import '../../widgets/app_background.dart';
import '../../widgets/player_half.dart';
import 'zwei_geraete_connection_lost_page.dart';

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
  late ScoreController controller;
  late DatabaseReference sessionRef;

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
    _listenToGameState();
  }

  void _listenToSession() {
    sessionRef.onValue.listen((event) {
      if (!mounted) return;

      if (!event.snapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ZweiGeraeteConnectionLostPage(
              reason: "Die Session wurde beendet.",
            ),
          ),
        );
        return;
      }

      final map = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (map["status"] == "closed") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ZweiGeraeteConnectionLostPage(
              reason: "Der Koordinator hat das Spiel beendet.",
            ),
          ),
        );
        return;
      }

      if (!widget.isCoordinator && map["coordinatorConnected"] == false) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ZweiGeraeteConnectionLostPage(
              reason: "Der Koordinator ist nicht mehr verbunden.",
            ),
          ),
        );
        return;
      }
    });
  }

  void _listenToGameState() {
    sessionRef.child("gameState").onValue.listen((event) {
      if (!mounted) return;
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      setState(() {
        controller = ScoreController.fromJson(data);
      });
    });
  }

  void _sync() {
    sessionRef.child("gameState").set(controller.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final game = controller.game;

    final bool isTeam1 = widget.isCoordinator;
    final int myPlayer = isTeam1 ? 1 : 2;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              isTeam1 ? widget.team1 : widget.team2,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PlayerHalf(
                player: myPlayer,
                game: game,
                leftTeam: widget.team1,
                rightTeam: widget.team2,
                table: controller.table,
                controller: controller,
                onUndo: () {
                  controller.undo();
                  _sync();
                  setState(() {});
                },
                onToggleTense: () {
                  controller.toggleTense(myPlayer);
                  _sync();
                  setState(() {});
                },
                onPrevGame: () {
                  controller.prevGame();
                  _sync();
                  setState(() {});
                },
                onNextGame: () {
                  controller.nextGame();
                  _sync();
                  setState(() {});
                },
                onPickTable: (v) {
                  controller.table = v;
                  _sync();
                  setState(() {});
                },
                onAddScore: (v) {
                  controller.addScore(myPlayer, v);
                  _sync();
                  setState(() {});
                },
                canNext: controller.canNext,
                canPrev: controller.canPrev,
                currentGame: controller.currentGame,
                viewRound: controller.currentRound,
                onPrevRound: widget.isCoordinator
                    ? () {
                        if (controller.hasPrevRound(controller.currentRound)) {
                          controller.currentRound--;
                          _sync();
                          setState(() {});
                        }
                      }
                    : null,
                onNextRound: widget.isCoordinator
                    ? () {
                        if (controller.hasNextRound(controller.currentRound)) {
                          controller.currentRound++;
                          _sync();
                          setState(() {});
                        }
                      }
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            if (widget.isCoordinator)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    controller.newRound();
                    _sync();
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Neue Runde", style: TextStyle(fontSize: 22)),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
