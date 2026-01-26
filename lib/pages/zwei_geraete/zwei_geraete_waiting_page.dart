import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../widgets/app_background.dart';
import 'zwei_geraete_game_page.dart';
import 'zwei_geraete_connection_lost_page.dart';

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
  bool coordinatorConnected = false;
  bool playerConnected = false;

  @override
  void initState() {
    super.initState();
    sessionRef = FirebaseDatabase.instance.ref("sessions/${widget.sessionId}");
    _listenForConnections();
  }

  void _listenForConnections() {
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

      coordinatorConnected = map["coordinatorConnected"] ?? false;
      playerConnected = map["playerConnected"] ?? false;

      if (map["status"] == "closed") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ZweiGeraeteConnectionLostPage(
              reason: "Der Koordinator hat die Session beendet.",
            ),
          ),
        );
        return;
      }

      if (coordinatorConnected && playerConnected) {
        if (widget.isCoordinator) {
          sessionRef.update({"status": "ready"});
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ZweiGeraeteGamePage(
              sessionId: widget.sessionId,
              team1: widget.team1,
              team2: widget.team2,
              maxPoints: widget.maxPoints,
              totalRounds: widget.totalRounds,
              gamesPerRound: widget.gamesPerRound,
              gschneidertDoppelt: widget.gschneidertDoppelt,
              isCoordinator: widget.isCoordinator,
            ),
          ),
        );
      }

      setState(() {});
    });
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
                  "Warte auf Verbindung…",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 40),
                _statusTile("Koordinator verbunden", coordinatorConnected),
                const SizedBox(height: 20),
                _statusTile("Mitspieler verbunden", playerConnected),
                const SizedBox(height: 40),
                Text(
                  "Session ID:",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.sessionId,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusTile(String label, bool active) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade300 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? Colors.green.shade700 : Colors.grey.shade600,
          width: 2,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: active ? Colors.green.shade900 : Colors.grey.shade800,
        ),
      ),
    );
  }
}
