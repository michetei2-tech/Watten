import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import 'scoreboard_page.dart';
import 'start_page.dart';
import 'zwei_geraete_setup_page.dart';
import 'setup/einstellungen_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController team1Controller = TextEditingController();
  final TextEditingController team2Controller = TextEditingController();

  int maxPoints = 11;
  int totalRounds = 5;
  int gamesPerRound = 5;
  bool gschneidertDoppelt = true;
  String spielmodus = 'ein';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Spiel Setup',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),

                const SizedBox(height: 30),

                _buildInputField(
                  controller: team1Controller,
                  label: 'Team 1 (optional)',
                ),

                const SizedBox(height: 16),

                _buildInputField(
                  controller: team2Controller,
                  label: 'Team 2 (optional)',
                ),

                const SizedBox(height: 40),

                // EINSTELLUNGSBUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openSettings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Einstellungen',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // START BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Starten',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // STARTSEITE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const StartPage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Startseite',
                      style: TextStyle(fontSize: 22),
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

  // ------------------------------------------------------------
  // EINSTELLUNGEN ÖFFNEN
  // ------------------------------------------------------------
  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EinstellungenPage(
          maxPoints: maxPoints,
          totalRounds: totalRounds,
          gamesPerRound: gamesPerRound,
          gschneidertDoppelt: gschneidertDoppelt,
          spielmodus: spielmodus,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        maxPoints = result["maxPoints"];
        totalRounds = result["totalRounds"];
        gamesPerRound = result["gamesPerRound"];
        gschneidertDoppelt = result["gschneidertDoppelt"];
        spielmodus = result["spielmodus"];
      });
    }
  }

  // ------------------------------------------------------------
  // UI-Bausteine
  // ------------------------------------------------------------
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SPIEL STARTEN
  // ------------------------------------------------------------
  void _startGame() {
    final t1 = team1Controller.text.trim();
    final t2 = team2Controller.text.trim();

    if (spielmodus == 'ein') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScoreboardPage(
            isTournament: false,
            team1: t1,
            team2: t2,
            totalRounds: totalRounds,
            maxPoints: maxPoints,
            gamesPerRound: gamesPerRound,
            gschneidertDoppelt: gschneidertDoppelt,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ZweiGeraeteSetupPage(),
        ),
      );
    }
  }
}
