import 'package:flutter/material.dart';

import '../logic/storage_manager.dart';
import '../logic/score_controller.dart';
import '../widgets/app_background.dart';
import 'scoreboard_page.dart';
import 'start_page.dart';

class LoadGamePage extends StatefulWidget {
  const LoadGamePage({super.key});

  @override
  State<LoadGamePage> createState() => _LoadGamePageState();
}

class _LoadGamePageState extends State<LoadGamePage> {
  late Future<List<SavedGame>> _futureGames;

  @override
  void initState() {
    super.initState();
    _futureGames = StorageManager.loadAllGames();
  }

  Future<void> _reload() async {
    setState(() {
      _futureGames = StorageManager.loadAllGames();
    });
  }

  void _openGame(SavedGame game) {
    final controller = game.controller;
    Navigator.pushReplacement(
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
    );
  }

  Future<void> _deleteGame(SavedGame game) async {
    await StorageManager.deleteGame(game.name);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Spiel laden",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<SavedGame>>(
                  future: _futureGames,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Fehler beim Laden der Spiele.",
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      );
                    }
                    final games = snapshot.data ?? [];
                    if (games.isEmpty) {
                      return Center(
                        child: Text(
                          "Keine gespeicherten Spiele vorhanden.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: games.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final g = games[index];
                        final dateStr =
                            "${g.savedAt.day.toString().padLeft(2, '0')}.${g.savedAt.month.toString().padLeft(2, '0')}.${g.savedAt.year} "
                            "${g.savedAt.hour.toString().padLeft(2, '0')}:${g.savedAt.minute.toString().padLeft(2, '0')}";

                        return GestureDetector(
                          onTap: () => _openGame(g),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.blue.shade300, width: 2),
                            ),
                            child: Row(
                              children: [
                                // TEXTBEREICH
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Gespeichert am $dateStr",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // LÖSCHEN BUTTON (größer)
                                GestureDetector(
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text("Spiel löschen"),
                                        content: Text(
                                            "Möchtest du „${g.name}“ wirklich löschen?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text("Abbrechen"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text("Löschen"),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _deleteGame(g);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 32,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // SPIEL STARTEN BUTTON
                                GestureDetector(
                                  onTap: () => _openGame(g),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.green.shade700,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const StartPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Zurück zur Startseite",
                      style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
