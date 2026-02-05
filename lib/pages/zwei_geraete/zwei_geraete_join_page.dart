import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../widgets/app_background.dart';
import 'zwei_geraete_waiting_page.dart';

class ZweiGeraeteJoinPage extends StatefulWidget {
  const ZweiGeraeteJoinPage({super.key});

  @override
  State<ZweiGeraeteJoinPage> createState() => _ZweiGeraeteJoinPageState();
}

class _ZweiGeraeteJoinPageState extends State<ZweiGeraeteJoinPage> {
  final TextEditingController codeController = TextEditingController();
  bool loading = false;
  String? errorMessage;
  bool navigated = false;

  Future<void> _joinSession(String sessionId) async {
    if (navigated) return;
    navigated = true;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    final ref = FirebaseDatabase.instance.ref("sessions/$sessionId");
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      setState(() {
        loading = false;
        errorMessage = "Session nicht gefunden.";
        navigated = false;
      });
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    if (data["status"] != "waiting") {
      setState(() {
        loading = false;
        errorMessage = "Session ist nicht mehr verfügbar.";
        navigated = false;
      });
      return;
    }

    final team1 = (data["team1"] as String).isEmpty ? "Team 1" : data["team1"];
    final team2 = (data["team2"] as String).isEmpty ? "Team 2" : data["team2"];

    await ref.update({"playerConnected": true});

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ZweiGeraeteWaitingPage(
          sessionId: sessionId,
          team1: team1,
          team2: team2,
          maxPoints: data["maxPoints"],
          totalRounds: data["totalRounds"],
          gamesPerRound: data["gamesPerRound"],
          gschneidertDoppelt: data["gschneidertDoppelt"],
          isCoordinator: false,
        ),
      ),
    );
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
                "Zwei Geräte – Beitreten",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Gib den Zahlencode ein.",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: "Zahlencode",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () => _joinSession(codeController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Beitreten", style: TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
