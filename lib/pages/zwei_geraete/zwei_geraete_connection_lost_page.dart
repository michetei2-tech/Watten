import 'package:flutter/material.dart';

import '../../widgets/app_background.dart';
import '../scoreboard_page.dart';
import '../../logic/score_controller.dart';

class ZweiGeraeteConnectionLostPage extends StatelessWidget {
  final String reason;
  final String team1;
  final String team2;
  final int maxPoints;
  final int totalRounds;
  final int gamesPerRound;
  final bool gschneidertDoppelt;
  final ScoreController controller;

  const ZweiGeraeteConnectionLostPage({
    super.key,
    required this.reason,
    required this.team1,
    required this.team2,
    required this.maxPoints,
    required this.totalRounds,
    required this.gamesPerRound,
    required this.gschneidertDoppelt,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTeam1 = team1.isEmpty ? "Team 1" : team1;
    final effectiveTeam2 = team2.isEmpty ? "Team 2" : team2;

    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 80, color: Colors.red.shade700),
                const SizedBox(height: 20),

                Text(
                  "Verbindung verloren",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue.shade700,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScoreboardPage(
                            isTournament: false,
                            team1: effectiveTeam1,
                            team2: effectiveTeam2,
                            totalRounds: totalRounds,
                            maxPoints: maxPoints,
                            gamesPerRound: gamesPerRound,
                            gschneidertDoppelt: gschneidertDoppelt,
                            loadedController: controller,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Im Ein‑Geräte‑Modus weiterspielen",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
