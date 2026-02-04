import 'package:flutter/material.dart';

import '../logic/score_controller.dart';
import '../widgets/player_half.dart';
import '../widgets/app_background.dart';
import 'auswertung_page.dart';

class ScoreboardPage extends StatefulWidget {
  final bool isTournament;
  final String team1;
  final String team2;
  final int totalRounds;
  final int maxPoints;
  final int gamesPerRound;
  final bool gschneidertDoppelt;
  final ScoreController? loadedController;

  const ScoreboardPage({
    super.key,
    required this.isTournament,
    required this.team1,
    required this.team2,
    required this.totalRounds,
    required this.maxPoints,
    required this.gamesPerRound,
    required this.gschneidertDoppelt,
    this.loadedController,
  });

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  late final ScoreController controller;
  int viewRound = 0;

  @override
  void initState() {
    super.initState();
    if (widget.loadedController != null) {
      controller = widget.loadedController!;
    } else {
      controller = ScoreController(
        maxPoints: widget.maxPoints,
        totalRounds: widget.totalRounds,
        gamesPerRound: widget.gamesPerRound,
        gschneidertDoppelt: widget.gschneidertDoppelt,
        team1: widget.team1,
        team2: widget.team2,
      );
      controller.saveLastGame();
    }
  }

  Future<void> _openAuswertung() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuswertungPage(
          controller: controller,
          team1: widget.team1,
          team2: widget.team2,
        ),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final games = controller.getRoundGames(viewRound);
    final game = games[controller.currentGame];

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // obere Hälfte (gespiegelt)
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
                  onUndo: () => setState(controller.undo),
                  onToggleTense: () =>
                      setState(() => controller.toggleTense(2)),
                  onPrevGame: () => setState(controller.prevGame),
                  onNextGame: () => setState(controller.nextGame),
                  onPickTable: (v) =>
                      setState(() => controller.table = v),
                  onAddScore: (v) =>
                      setState(() => controller.addScore(2, v)),
                  canNext: controller.canNext,
                  canPrev: controller.canPrev,
                  currentGame: controller.currentGame,
                  viewRound: viewRound,
                  onPrevRound: () {
                    if (controller.hasPrevRound(viewRound)) {
                      setState(() {
                        viewRound++;
                        controller.currentGame = 0;
                      });
                    }
                  },
                  onNextRound: () {
                    // Neue Runde wird NUR hier erzeugt
                    setState(() {
                      controller.newRound();
                      viewRound = 0;          // aktuelle Runde anzeigen
                      controller.currentGame = 0; // erstes Spiel
                    });
                  },
                  onAuswertung: _openAuswertung,
                ),
              ),
            ),

            // untere Hälfte
            Expanded(
              child: PlayerHalf(
                player: 1,
                game: game,
                leftTeam: widget.team1,
                rightTeam: widget.team2,
                table: controller.table,
                controller: controller,
                onUndo: () => setState(controller.undo),
                onToggleTense: () =>
                    setState(() => controller.toggleTense(1)),
                onPrevGame: () => setState(controller.prevGame),
                onNextGame: () => setState(controller.nextGame),
                onPickTable: (v) =>
                    setState(() => controller.table = v),
                onAddScore: (v) =>
                    setState(() => controller.addScore(1, v)),
                canNext: controller.canNext,
                canPrev: controller.canPrev,
                currentGame: controller.currentGame,
                viewRound: viewRound,
                onPrevRound: () {
                  if (controller.hasPrevRound(viewRound)) {
                    setState(() {
                      viewRound++;
                      controller.currentGame = 0;
                    });
                  }
                },
                onNextRound: () {
                  setState(() {
                    controller.newRound();
                    viewRound = 0;
                    controller.currentGame = 0;
                  });
                },
                onAuswertung: _openAuswertung,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
