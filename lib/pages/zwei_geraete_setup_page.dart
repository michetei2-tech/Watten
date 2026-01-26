import 'package:flutter/material.dart';

class ZweiGeraeteSetupPage extends StatelessWidget {
  const ZweiGeraeteSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zwei Geräte – Verbindung')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gerät A startet als Host.\nGerät B scannt später den QR‑Code.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // später: Host starten + QR-Code anzeigen
              },
              child: const Text('Host starten'),
            ),
          ],
        ),
      ),
    );
  }
}
