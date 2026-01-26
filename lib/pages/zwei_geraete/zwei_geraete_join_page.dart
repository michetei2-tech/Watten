import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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

  // ------------------------------------------------------------
  // SESSION PRÜFEN
  // ------------------------------------------------------------
  Future<void> _joinSession(String sessionId) async {
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
      });
      return;
    }

    final data = snapshot.value as Map;

    if (data["status"] != "waiting") {
      setState(() {
        loading = false;
        errorMessage = "Session ist nicht mehr verfügbar.";
      });
      return;
    }

    // Spieler als verbunden markieren
    await ref.update({"playerConnected": true});

    // Weiter zur Waiting Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZweiGeraeteWaitingPage(
          sessionId: sessionId,
          team1: data["team1"],
          team2: data["team2"],
          maxPoints: data["maxPoints"],
          totalRounds: data["totalRounds"],
          gamesPerRound: data["gamesPerRound"],
          gschneidertDoppelt: data["gschneidertDoppelt"],
          isCoordinator: false,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // QR SCANNER
  // ------------------------------------------------------------
  Future<void> _scanQrCode() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRScannerPage(
          onScan: (code) {
            Navigator.pop(context);
            codeController.text = code;
            _joinSession(code);
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
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
                "Gib den Zahlencode ein oder scanne den QR‑Code.",
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

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: loading ? null : _scanQrCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("QR‑Code scannen", style: TextStyle(fontSize: 22)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// QR SCANNER PAGE
// ------------------------------------------------------------
class QRScannerPage extends StatefulWidget {
  final void Function(String code) onScan;

  const QRScannerPage({super.key, required this.onScan});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: (ctrl) {
              controller = ctrl;
              ctrl.scannedDataStream.listen((scanData) {
                widget.onScan(scanData.code ?? "");
              });
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              child: const Text("Zurück"),
            ),
          ),
        ],
      ),
    );
  }
}
