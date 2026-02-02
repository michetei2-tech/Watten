import 'package:flutter/material.dart';

import '../logic/score_controller.dart';
import '../widgets/player_half.dart';
import '../widgets/app_background.dart';
import 'auswertung_page.dart';
import 'start_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final games = controller.getRoundGames(viewRound);
    final game = games[controller.currentGame];

    final screenHeight = MediaQuery.of(context).size.height;

    // Jede Hälfte darf maximal 45% der Höhe einnehmen
    final maxHalfHeight = screenHeight * 0.45;

    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            // OBERES SCOREBOARD (gespiegelt)
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHalfHeight),
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
                    onToggleTense: () => setState(() => controller.toggleTense(2)),
                    onPrevGame: () => setState(controller.prevGame),
                    onNextGame: () => setState(controller.nextGame),
                    onPickTable: (v) => setState(() => controller.table = v),
                    onAddScore: (v) => setState(() => controller.addScore(2, v)),
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
                      if (controller.hasNextRound(viewRound)) {
                        setState(() {
                          viewRound--;
                          controller.currentGame = 0;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),

            // UNTERES SCOREBOARD
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHalfHeight),
                child: PlayerHalf(
                  player: 1,
                  game: game,
                  leftTeam: widget.team1,
                  rightTeam: widget.team2,
                  table: controller.table,
                  controller: controller,
                  onUndo: () => setState(controller.undo),
                  onToggleTense: () => setState(() => controller.toggleTense(1)),
                  onPrevGame: () => setState(controller.prevGame),
                  onNextGame: () => setState(controller.nextGame),
                  onPickTable: (v) => setState(() => controller.table = v),
                  onAddScore: (v) => setState(() => controller.addScore(1, v)),
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
                    if (controller.hasNextRound(viewRound)) {
                      setState(() {
                        viewRound--;
                        controller.currentGame = 0;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),

            // BUTTON-LEISTE (nur Tisch + Auswertung)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final buttonHeight =
                      (screenHeight * 0.07).clamp(40.0, 55.0);
                  final halfWidth = constraints.maxWidth / 2 - 12;

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _actionButton(
                        text: controller.table == null
                            ? "Tisch"
                            : "Tisch ${controller.table}",
                        color: Colors.blue.shade600,
                        height: buttonHeight,
                        width: isWide ? 160 : halfWidth,
                        onTap: () async {
                          final selected = await _selectTable(context);
                          setState(() => controller.table = selected);
                        },
                      ),
                      _actionButton(
                        text: "Auswertung",
                        color: Colors.orange.shade700,
                        height: buttonHeight,
                        width: isWide ? 160 : halfWidth,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AuswertungPage(
                                controller: controller,
                                team1: widget.team1,
                                team2: widget.team2,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required double height,
    required double width,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: FittedBox(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Future<int?> _selectTable(BuildContext context) async {
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Tisch auswählen"),
          content: SizedBox(
            width: double.maxFinite,
            height: 250,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 20,
              itemBuilder: (_, index) {
                final number = index + 1;
                return GestureDetector(
                  onTap: () => Navigator.pop(ctx, number),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "$number",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
