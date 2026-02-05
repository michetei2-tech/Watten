import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';

class EinstellungenPage extends StatefulWidget {
  final int maxPoints;
  final int totalRounds;
  final int gamesPerRound;
  final bool gschneidertDoppelt;
  final String spielmodus;

  const EinstellungenPage({
    super.key,
    required this.maxPoints,
    required this.totalRounds,
    required this.gamesPerRound,
    required this.gschneidertDoppelt,
    required this.spielmodus,
  });

  @override
  State<EinstellungenPage> createState() => _EinstellungenPageState();
}

class _EinstellungenPageState extends State<EinstellungenPage> {
  late int maxPoints;
  late int totalRounds;
  late int gamesPerRound;
  late bool gschneidertDoppelt;
  late String spielmodus;

  @override
  void initState() {
    super.initState();
    maxPoints = widget.maxPoints;
    totalRounds = widget.totalRounds;
    gamesPerRound = widget.gamesPerRound;
    gschneidertDoppelt = widget.gschneidertDoppelt;
    spielmodus = widget.spielmodus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  "Einstellungen",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),

                const SizedBox(height: 40),

                // MAX PUNKTE
                _sectionTitle("Max. Punkte"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _bigButton("11", maxPoints == 11, () => setState(() => maxPoints = 11)),
                    _bigButton("15", maxPoints == 15, () => setState(() => maxPoints = 15)),
                    _iconOrNumberButton(
                      value: maxPoints,
                      isSelected: !(maxPoints == 11 || maxPoints == 15),
                      onTap: () async {
                        final value = await _pickNumber(context, maxPoints);
                        if (value != null) setState(() => maxPoints = value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // RUNDEN
                _sectionTitle("Runden"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _bigButton("5", totalRounds == 5, () => setState(() => totalRounds = 5)),
                    _bigButton("10", totalRounds == 10, () => setState(() => totalRounds = 10)),
                    _iconOrNumberButton(
                      value: totalRounds,
                      isSelected: !(totalRounds == 5 || totalRounds == 10),
                      onTap: () async {
                        final value = await _pickNumber(context, totalRounds);
                        if (value != null) setState(() => totalRounds = value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // SPIELE PRO RUNDE
                _sectionTitle("Spiele pro Runde"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _bigButton("5", gamesPerRound == 5, () => setState(() => gamesPerRound = 5)),
                    _bigButton("10", gamesPerRound == 10, () => setState(() => gamesPerRound = 10)),
                    _iconOrNumberButton(
                      value: gamesPerRound,
                      isSelected: !(gamesPerRound == 5 || gamesPerRound == 10),
                      onTap: () async {
                        final value = await _pickNumber(context, gamesPerRound);
                        if (value != null) setState(() => gamesPerRound = value);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Gschneidert doppelt
                _sectionTitle("Gschneidert doppelt"),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(() => gschneidertDoppelt = !gschneidertDoppelt),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: gschneidertDoppelt ? Colors.blue.shade700 : Colors.white,
                      foregroundColor: gschneidertDoppelt ? Colors.white : Colors.blue.shade700,
                      side: BorderSide(
                        color: Colors.blue.shade700,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Gschneidert doppelt",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // SPIELMODUS
                _sectionTitle("Spielmodus"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _modeButton("Ein Gerät", "ein"),
                    _modeButton("Zwei Geräte", "zwei"),
                  ],
                ),

                const SizedBox(height: 40),

                // ÜBERNEHMEN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "maxPoints": maxPoints,
                        "totalRounds": totalRounds,
                        "gamesPerRound": gamesPerRound,
                        "gschneidertDoppelt": gschneidertDoppelt,
                        "spielmodus": spielmodus,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Übernehmen", style: TextStyle(fontSize: 22)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _bigButton(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: selected ? Colors.blue.shade700 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? Colors.blue.shade700 : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconOrNumberButton({
    required int value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool isCustom = isSelected;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: isCustom ? Colors.blue.shade700 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCustom ? Colors.blue.shade700 : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Center(
              child: isCustom
                  ? Text(
                      "$value",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.grid_view, size: 28, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String label, String value) {
    final selected = spielmodus == value;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: GestureDetector(
          onTap: () => setState(() => spielmodus = value),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: selected ? Colors.blue.shade700 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? Colors.blue.shade700 : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<int?> _pickNumber(BuildContext context, int current) async {
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Zahl auswählen"),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 65,
              itemBuilder: (_, index) {
                if (index == 0) return const SizedBox.shrink();

                final number = index;

                return GestureDetector(
                  onTap: () => Navigator.pop(ctx, number),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "$number",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
