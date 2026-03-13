import 'dart:async';
import 'dart:html' as html;

class PwaInstallService {
  static final PwaInstallService _instance = PwaInstallService._internal();
  factory PwaInstallService() => _instance;
  PwaInstallService._internal();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onInstallAvailable => _controller.stream;

  void initialize() {
    html.window.addEventListener('pwa-install-available', (event) {
      _controller.add(true);
    });
  }

  Future<bool> triggerInstall() async {
    final result = await html.window.callMethod('pwaInstall', []);
    return result == true;
  }
}
