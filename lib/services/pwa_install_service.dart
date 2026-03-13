import 'dart:async';
import 'dart:html' as html;
import 'package:js/js_util.dart' as js_util;

class PwaInstallService {
  static final PwaInstallService _instance = PwaInstallService._internal();
  factory PwaInstallService() => _instance;
  PwaInstallService._internal();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onInstallAvailable => _controller.stream;

  void initialize() {
    // Event aus install.js empfangen
    html.window.addEventListener('pwa-install-available', (event) {
      _controller.add(true);
    });
  }

  Future<bool> triggerInstall() async {
    try {
      // JS-Funktion window.pwaInstall() aufrufen
      final result = await js_util.promiseToFuture(
        js_util.callMethod(html.window, 'pwaInstall', []),
      );

      return result == true;
    } catch (e) {
      // Falls JS nicht verfügbar ist
      return false;
    }
  }
}
