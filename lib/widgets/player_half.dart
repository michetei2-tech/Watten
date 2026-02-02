import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../logic/score_controller.dart';

class PlayerHalf extends StatefulWidget {
  final int player;
  final GameState game;

  final String leftTeam;
  final String rightTeam;
  final int? table;

  final VoidCallback onUndo;
  final VoidCallback onToggleTense;
  final VoidCallback onPrevGame;
  final VoidCallback onNextGame;

  final Function(int?) onPickTable;
  final Function(int points) onAddScore;

  final bool canNext;
  final bool canPrev;
  final int currentGame;

  final ScoreController controller;

  final int viewRound;
  final VoidCallback onPrevRound;
  final VoidCallback onNextRound;

  const PlayerHalf({
    super.key,
    required this.player,
    required this.game,
    required this.leftTeam,
    required this.rightTeam,
    required this.table,
    required this.onUndo,
    required this.onToggleTense,
    required this.onPrevGame,
    required this.onNextGame,
    required this.onPickTable,
    required this.onAddScore,
    required this.canNext,
    required this.canPrev,
    required this.currentGame,
    required this.controller,
    required this.viewRound,
    required this.onPrevRound,
    required this.onNextRound,
  });

  @override
  State<PlayerHalf> createState() => _PlayerHalfState();
}

class _PlayerHalfState extends State<PlayerHalf> {
  @override
  Widget build(BuildContext context) {
    final isP1 = widget.player == 1;
    final scoreLeft = isP1 ? widget.game.p1 : widget.game.p2;
    final scoreRight = isP1 ? widget.game.p2 : widget.game.p1;
    final points = isP1 ? widget.game.p1Points : widget.game.p2Points;
    final tense = isP1 ? widget.game.p1Tense : widget.game.p2Tense;

    final maxRoundsText = widget.controller.totalRounds == -1
        ? '∞'
        : widget.controller.totalRounds.toString();

    final screenHeight = MediaQuery.of(context).size.height;

    final arrowSize = 48.0; // OPTION C
    final scoreFontSize = (screenHeight * 0.05).clamp(26.0, 40.0);
    final chipFontSize = (screenHeight * 0.03).clamp(18.0, 26.0);
    final buzzerSize = (screenHeight * 0.065).clamp(38.0, 70.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TEAM-NAMEN
              Text(
                '${widget.leftTeam} vs ${widget.rightTeam}',
                style: TextStyle(
                  fontSize: (screenHeight * 0.03).clamp(16.0, 22.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),

              const SizedBox(height: 6),

              // SCORE
              Text(
                '$scoreLeft : $scoreRight',
                style: TextStyle(
                  fontSize: scoreFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // SPIEL + RUNDE NAVIGATION
              Card(
                color: Colors.blue.shade100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Column(
                    children: [
                      // SPIEL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: arrowSize,
                            onPressed: widget.canPrev ? widget.onPrevGame : null,
                            icon: const Icon(Icons.arrow_left),
                          ),
                          Expanded(
                            child: Text(
                              'Spiel ${widget.currentGame + 1} / ${widget.controller.gamesPerRound}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (screenHeight * 0.025).clamp(14.0, 20.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: arrowSize,
                            onPressed: () {
                              // NEUES SPIEL
                              widget.onNextGame();
                            },
                            icon: const Icon(Icons.arrow_right),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // RUNDE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: arrowSize,
                            onPressed: widget.controller.hasPrevRound(widget.viewRound)
                                ? widget.onPrevRound
                                : null,
                            icon: const Icon(Icons.arrow_left),
                          ),
                          Expanded(
                            child: Text(
                              'Runde ${widget.controller.currentRound - widget.viewRound} / $maxRoundsText',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (screenHeight * 0.025).clamp(14.0, 20.0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            iconSize: arrowSize,
                            onPressed: () {
                              // NEUE RUNDE
                              widget.controller.newRound();
                              setState(() {});
                            },
                            icon: const Icon(Icons.arrow_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // PUNKTE-ANZEIGE
              Container(
                height: (screenHeight * 0.12).clamp(70.0, 130.0),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: tense ? Colors.red.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: tense ? Colors.red.shade300 : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: points.isEmpty
                    ? Center(
                        child: Text(
                          'Noch keine Punkte',
                          style: TextStyle(
                            fontSize: (screenHeight * 0.025).clamp(14.0, 20.0),
                            color: tense ? Colors.red.shade700 : Colors.grey,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: points
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Chip(
                                    label: Text(
                                      '$e',
                                      style: TextStyle(
                                        fontSize: chipFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    backgroundColor: tense
                                        ? Colors.red.shade200
                                        : Colors.blue.shade100,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
              ),

              const SizedBox(height: 10),

              // BUZZER-LEISTE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buzzerButton(
                    icon: Icons.radio_button_checked,
                    iconColor: Colors.redAccent,
                    onTap: widget.onToggleTense,
                    size: buzzerSize,
                  ),
                  _buzzerButton(
                    text: "2",
                    onTap: () => widget.onAddScore(2),
                    size: buzzerSize,
                  ),
                  _buzzerButton(
                    text: "3",
                    onTap: () => widget.onAddScore(3),
                    size: buzzerSize,
                  ),
                  _buzzerButton(
                    icon: Icons.grid_view,
                    onTap: () => _openNumberPad(context),
                    size: buzzerSize,
                  ),
                  _buzzerButton(
                    icon: Icons.undo,
                    onTap: widget.onUndo,
                    size: buzzerSize,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buzzerButton({
    String? text,
    IconData? icon,
    Color? iconColor,
    required VoidCallback onTap,
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.blue.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: icon != null
            ? Icon(
                icon,
                size: size * 0.45,
                color: iconColor ?? Colors.white,
              )
            : Text(
                text!,
                style: TextStyle(
                  fontSize: size * 0.35,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _openNumberPad(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: 20,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (_, i) {
                final value = i + 1;
                return ElevatedButton(
                  onPressed: () {
                    widget.onAddScore(value);
                    Navigator.of(ctx).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
