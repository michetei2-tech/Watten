import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../services/pwa_install_service.dart';

class PwaInstallButton extends StatefulWidget {
  const PwaInstallButton({super.key});

  @override
  State<PwaInstallButton> createState() => _PwaInstallButtonState();
}

class _PwaInstallButtonState extends State<PwaInstallButton> {
  bool _visible = false;

  bool get _isStandalone {
    return html.window.matchMedia('(display-mode: standalone)').matches;
  }

  bool get _isIOS {
    final ua = html.window.navigator.userAgent.toLowerCase();
    return ua.contains("iphone") || ua.contains("ipad") || ua.contains("ipod");
  }

  bool get _isSafari {
    final ua = html.window.navigator.userAgent.toLowerCase();
    return _isIOS && ua.contains("safari") && !ua.contains("crios") && !ua.contains("fxios");
  }

  @override
  void initState() {
    super.initState();

    if (_isStandalone) return;

    if (_isSafari) {
      setState(() => _visible = true);
      return;
    }

    PwaInstallService().onInstallAvailable.listen((_) {
      if (!_isStandalone) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    // iOS Safari → Hinweis mit Icon
    if (_isSafari) {
      return Positioned(
        bottom: 20,
        right: 20,
        child: SizedBox(
          width: 220,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("App Installieren"),
                  content: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // iOS Share Icon (rein in Flutter gebaut)
                      Icon(
                        Icons.ios_share,
                        size: 32,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Auf iOS bitte das Teilen-Symbol antippen "
                          "und „Zum Home-Bildschirm“ wählen.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
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
              elevation: 6,
            ),
            child: const Text(
              'App Installieren',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Android / Desktop → echtes Install-Prompt
    return Positioned(
      bottom: 20,
      right: 20,
      child: SizedBox(
        width: 220,
        child: ElevatedButton(
          onPressed: () async {
            await PwaInstallService().triggerInstall();
            setState(() => _visible = false);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
          child: const Text(
            'App Installieren',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
