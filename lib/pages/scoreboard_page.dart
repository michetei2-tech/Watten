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

  /// viewRound = 0 → aktuelle Runde
  /// viewRound > 0 → History
  int viewRound = 0;

  /// Anzeigeindex des Spiels
  int viewGame = 0;

  bool get isCurrentRound => viewRound == 0;

  late final String effectiveTeam1;
  late final String effectiveTeam2;

  @override
  void initState() {
    super.initState();

    // Automatische Teamnamen
    effectiveTeam1 = widget.team1.isEmpty ? "Team 1" : widget.team1;
    effectiveTeam2 = widget.team2.isEmpty ? "Team 2" : widget.team2;

    if (widget.loadedController != null) {
      controller = widget.loadedController!;
    } else {
      controller = ScoreController(
        maxPoints: widget.maxPoints,
        totalRounds: widget.totalRounds,
        gamesPerRound: widget.gamesPerRound,
        gschneidertDoppelt: widget.gschneidertDoppelt,
        team1: effectiveTeam1,
        team2: effectiveTeam2,
      );
      controller.saveLastGame();
    }

    viewGame = controller.currentGame;
  }

  Future<void> _openAuswertung() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuswertungPage(
          controller: controller,
          team1: effectiveTeam1,
          team2: effectiveTeam2,
        ),
      ),
    );
    setState(() {});
  }

  // ---------- SPIEL-NAVIGATION ----------

  bool get _canPrevGame => viewGame > 0;

  bool get _canNextGame {
    final games = controller.getRoundGames(viewRound);
    if (viewGame >= games.length - 1) return false;

    final next = games[viewGame + 1];
    return next.p1 > 0 || next.p2 > 0;
  }

  void _handlePrevGame() {
    if (_canPrevGame) {
      setState(() => viewGame--);
    }
  }

  void _handleNextGame() {
    // History
    if (_canNextGame) {
      setState(() => viewGame++);
      return;
    }

    // Aktuelle Runde → echtes nextGame()
    if (isCurrentRound && controller.canNext) {
      setState(() {
        controller.nextGame();
        viewGame = controller.currentGame;
      });
    }
  }

  // ---------- RUNDEN-NAVIGATION ----------

  bool get _hasHistory => controller.allRounds.isNotEmpty;

  bool get _canPrevRound => viewRound < controller.allRounds.length;

  bool get _canNextRound => viewRound > 0;

  void _handlePrevRound() {
    if (!_hasHistory) return;

    setState(() {
      if (viewRound == 0) {
        viewRound = 1;
      } else if (viewRound < controller.allRounds.length) {
        viewRound++;
      }
      viewGame = 0;
    });
  }

  void _handleNextRound() {
    if (viewRound == 0) {
      setState(() {
        controller.newRound();
        viewRound = 0;
        viewGame = 0;
      });
      return;
    }

    if (_canNextRound) {
      setState(() {
        viewRound--;
        viewGame = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final games = controller.getRoundGames(viewRound);
    final game = games[viewGame];

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
                  leftTeam: effectiveTeam2,
                  rightTeam: effectiveTeam1,
                  table: controller.table,
                  controller: controller,
                  onUndo: () => setState(controller.undo),
                  onToggleTense: () =>
                      setState(() => controller.toggleTense(2)),

                  onPrevGame: _handlePrevGame,
                  onNextGame: _handleNextGame,

                  onPickTable: (v) =>
                      setState(() => controller.table = v),
                  onAddScore: (v) {
                    if (isCurrentRound) {
                      setState(() => controller.addScore(2, v));
                      viewGame = controller.currentGame;
                    }
                  },

                  canNext: _canNextGame,
                  canPrev: _canPrevGame,
                  currentGame: viewGame,
                  viewRound: viewRound,

                  onPrevRound: _handlePrevRound,
                  onNextRound: _handleNextRound,

                  onAuswertung: _openAuswertung,
                ),
              ),
            ),

            Expanded(
              child: PlayerHalf(
                player: 1,
                game: game,
                leftTeam: effectiveTeam1,
                rightTeam: effectiveTeam2,
                table: controller.table,
                controller: controller,
                onUndo: () => setState(controller.undo),
                onToggleTense: () =>
                    setState(() => controller.toggleTense(1)),

                onPrevGame: _handlePrevGame,
                onNextGame: _handleNextGame,

                onPickTable: (v) =>
                    setState(() => controller.table = v),
                onAddScore: (v) {
                  if (isCurrentRound) {
                    setState(() => controller.addScore(1, v));
                    viewGame = controller.currentGame;
                  }
                },

                canNext: _canNextGame,
                canPrev: _canPrevGame,
                currentGame: viewGame,
                viewRound: viewRound,

                onPrevRound: _handlePrevRound,
                onNextRound: _handleNextRound,

                onAuswertung: _openAuswertung,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
