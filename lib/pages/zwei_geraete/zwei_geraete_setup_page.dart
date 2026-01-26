import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../widgets/app_background.dart';
import 'zwei_geraete_waiting_page.dart';

class ZweiGeraeteSetupPage extends StatefulWidget {
  final String team1;
  final String team2;
  final int maxPoints;
  final int totalRounds;
  final int gamesPerRound;
  final bool gschneidertDoppelt;

  const ZweiGeraeteSetupPage({
    super.key,
    required this.team1,
    required this.team2,
    required this.maxPoints,
    required this.totalRounds,
    required this.gamesPerRound,
    required this.gschneidertDoppelt,
  });

  @override
  State<ZweiGeraeteSetupPage> createState() => _ZweiGeraeteSetupPageState();
}

class _ZweiGeraeteSetupPageState extends State<ZweiGeraeteSetupPage> {
  late String sessionId;
  late DatabaseReference sessionRef;

  @override
  void initState() {
    super.initState();
    _createSession();
  }

  void _createSession() {
    sessionId = _generateCode(6);

    sessionRef = FirebaseDatabase.instance.ref("sessions/$sessionId");

    sessionRef.set({
      "status": "waiting",
      "team1": widget.team1,
      "team2": widget.team2,
      "maxPoints": widget.maxPoints,
      "totalRounds": widget.totalRounds,
      "gamesPerRound": widget.gamesPerRound,
      "gschneidertDoppelt": widget.gschneidertDoppelt,
      "coordinatorConnected": true,
      "playerConnected": false,
    });
  }

  String _generateCode(int length) {
    final rand = Random();
    const chars = "0123456789";
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                "Zwei Geräte – Koordinator",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Gib diesen Code an das zweite Gerät weiter:",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade700, width: 3),
                ),
                child: Text(
                  sessionId,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Oder scanne den QR‑Code:",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: sessionId,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZweiGeraeteWaitingPage(
                          sessionId: sessionId,
                          team1: widget.team1,
                          team2: widget.team2,
                          maxPoints: widget.maxPoints,
                          totalRounds: widget.totalRounds,
                          gamesPerRound: widget.gamesPerRound,
                          gschneidertDoppelt: widget.gschneidertDoppelt,
                          isCoordinator: true,
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
                    "Weiter",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
