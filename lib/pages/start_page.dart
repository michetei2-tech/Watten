import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_background.dart';
import 'setup_page.dart';
import 'scoreboard_page.dart';
import '../logic/score_controller.dart';
import 'load_game_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool hasLastGame = false;

  @override
  void initState() {
    super.initState();
    _checkLastGame();
  }

  Future<void> _checkLastGame() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.containsKey("lastGame");
    setState(() => hasLastGame = exists);
  }

  Future<void> _loadLastGame(BuildContext context) async {
    final controller = await ScoreController.loadLastGame();
    if (controller == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScoreboardPage(
          isTournament: false,
          team1: controller.team1,
          team2: controller.team2,
          totalRounds: controller.totalRounds,
          maxPoints: controller.maxPoints,
          gamesPerRound: controller.gamesPerRound,
          gschneidertDoppelt: controller.gschneidertDoppelt,
          loadedController: controller,
        ),
      ),
    ).then((_) => _checkLastGame());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Spielmodus wählen',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),

                const SizedBox(height: 40),

                // SPIEL FORTSETZEN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasLastGame ? () => _loadLastGame(context) : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: hasLastGame
                          ? Colors.green.shade700
                          : Colors.grey.shade500,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Spiel fortsetzen',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // FREIES SPIEL
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      SharedPreferences.getInstance()
                          .then((prefs) => prefs.remove("lastGame"));

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SetupPage(),
                        ),
                      ).then((_) => _checkLastGame());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Freies Spiel',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SPIEL LADEN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoadGamePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Spiel laden',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // TURNIER — UNSICHTBAR, ABER IM LAYOUT
                Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Turniermodus folgt bald!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Turnier',
                        style: TextStyle(fontSize: 24),
                      ),
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
