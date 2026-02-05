import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../widgets/app_background.dart';
import 'zwei_geraete_game_page.dart';

class ZweiGeraeteWaitingPage extends StatefulWidget {
  final String sessionId;
  final String team1;
  final String team2;
  final int maxPoints;
  final int totalRounds;
  final int gamesPerRound;
  final bool gschneidertDoppelt;
  final bool isCoordinator;

  const ZweiGeraeteWaitingPage({
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
  State<ZweiGeraeteWaitingPage> createState() => _ZweiGeraeteWaitingPageState();
}

class _ZweiGeraeteWaitingPageState extends State<ZweiGeraeteWaitingPage> {
  late DatabaseReference sessionRef;
  bool navigated = false;

  late final String effectiveTeam1;
  late final String effectiveTeam2;

  @override
  void initState() {
    super.initState();

    // Automatische Teamnamen
    effectiveTeam1 = widget.team1.isEmpty ? "Team 1" : widget.team1;
    effectiveTeam2 = widget.team2.isEmpty ? "Team 2" : widget.team2;

    sessionRef = FirebaseDatabase.instance.ref("sessions/${widget.sessionId}");

    _listenToSession();

    // Markiere Verbindung
    sessionRef.update({
      widget.isCoordinator ? "coordinatorConnected" : "playerConnected": true,
    });
  }

  void _listenToSession() {
    sessionRef.onValue.listen((event) {
      if (!mounted || navigated) return;

      if (!event.snapshot.exists) {
        _showError("Die Session wurde beendet.");
        return;
      }

      final map = Map<String, dynamic>.from(event.snapshot.value as Map);

      final coordinatorConnected = map["coordinatorConnected"] ?? false;
      final playerConnected = map["playerConnected"] ?? false;

      // Wenn beide verbunden → Spiel starten
      if (coordinatorConnected && playerConnected) {
        _startGame();
      }
    });
  }

  void _startGame() {
    if (navigated) return;
    navigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ZweiGeraeteGamePage(
          sessionId: widget.sessionId,
          team1: effectiveTeam1,
          team2: effectiveTeam2,
          maxPoints: widget.maxPoints,
          totalRounds: widget.totalRounds,
          gamesPerRound: widget.gamesPerRound,
          gschneidertDoppelt: widget.gschneidertDoppelt,
          isCoordinator: widget.isCoordinator,
        ),
      ),
    );
  }

  void _showError(String msg) {
    if (navigated) return;
    navigated = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Spieler oder Koordinator verlässt die WaitingPage → Verbindung markieren
    sessionRef.update({
      widget.isCoordinator ? "coordinatorConnected" : "playerConnected": false,
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Warte auf Verbindung...",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.isCoordinator
                    ? "Warte auf den Mitspieler..."
                    : "Verbinde mit dem Koordinator...",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
