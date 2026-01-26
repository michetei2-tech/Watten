import 'package:flutter/material.dart';

import '../logic/score_controller.dart';
import '../logic/storage_manager.dart';
import 'app_background.dart';

class SaveGameDialog extends StatefulWidget {
  final ScoreController controller;
  final String team1;
  final String team2;

  const SaveGameDialog({
    super.key,
    required this.controller,
    required this.team1,
    required this.team2,
  });

  @override
  State<SaveGameDialog> createState() => _SaveGameDialogState();
}

class _SaveGameDialogState extends State<SaveGameDialog> {
  late TextEditingController _nameController;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final defaultName = _buildDefaultName(widget.team1, widget.team2);
    _nameController = TextEditingController(text: defaultName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _buildDefaultName(String team1, String team2) {
    final now = DateTime.now();
    final date =
        "${_two(now.day)}.${_two(now.month)}.${now.year}_${_two(now.hour)}-${_two(now.minute)}";

    final t1 = _sanitizeName(team1.isEmpty ? "Team1" : team1);
    final t2 = _sanitizeName(team2.isEmpty ? "Team2" : team2);

    return "${t1}_vs_${t2}_$date";
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  String _sanitizeName(String input) {
    var s = input;
    s = s.replaceAll("ä", "ae").replaceAll("Ä", "Ae");
    s = s.replaceAll("ö", "oe").replaceAll("Ö", "Oe");
    s = s.replaceAll("ü", "ue").replaceAll("Ü", "Ue");
    s = s.replaceAll("ß", "ss");
    s = s.replaceAll(" ", "_");
    s = s.replaceAll(RegExp(r"[^A-Za-z0-9_\-]"), "");
    return s;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = "Bitte einen Namen eingeben.");
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    await StorageManager.saveGame(name, widget.controller);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Spiel speichern",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dateiname",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hinweis: Teamnamen und Datum/Uhrzeit sind bereits vorbelegt.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Abbrechen", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isSaving ? "Speichern..." : "Speichern",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
