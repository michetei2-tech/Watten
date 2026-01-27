import 'package:flutter/material.dart';
import '../logic/score_controller.dart';
import '../models/game_state.dart';
import '../widgets/app_background.dart';
import '../widgets/save_game_dialog.dart';
import 'start_page.dart';
import 'package:pdf/pdf.dart';


// PDF
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../pdf/auswertung_pdf.dart';

class AuswertungPage extends StatelessWidget {
  final ScoreController controller;
  final String team1;
  final String team2;

  const AuswertungPage({
    super.key,
    required this.controller,
    required this.team1,
    required this.team2,
  });

  @override
  Widget build(BuildContext context) {
    final currentRound = controller.games;

    final List<List<GameState>> rounds = [
      if (currentRound.any((g) => g.p1 != 0 || g.p2 != 0)) currentRound,
      ...controller.allRounds,
    ];

    final int gamesPerRound = controller.gamesPerRound;

    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Auswertung",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: _buildTable(rounds, gamesPerRound),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  _button("Zurück", Colors.blue.shade700, () {
                    Navigator.pop(context);
                  }),

                  const SizedBox(width: 8),

                  _button("Startseite", Colors.red, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const StartPage()),
                      (route) => false,
                    );
                  }),

                  const SizedBox(width: 8),

                  _button("Speichern", Colors.blue.shade700, () async {
                    await showDialog(
                      context: context,
                      builder: (_) => SaveGameDialog(
                        controller: controller,
                        team1: team1,
                        team2: team2,
                      ),
                    );
                  }),

                  const SizedBox(width: 8),

                  // PDF BUTTON
                  _button("Download", Colors.blue.shade700, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfPreview(
                          build: (format) => AuswertungPdf(
                            controller: controller,
                            team1: team1,
                            team2: team2,
                          ).build(format),
                          allowPrinting: true,
                          allowSharing: true,
                          canChangeOrientation: true,
                          canChangePageFormat: true,
                          initialPageFormat: PdfPageFormat.a4.landscape,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(String text, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // UI TABELLE
  // ------------------------------------------------------------
  Widget _buildTable(List<List<GameState>> rounds, int gamesPerRound) {
    int totalMe = 0;
    int totalOpp = 0;
    int totalPointsMe = 0;
    int totalPointsOpp = 0;
    int totalRoundWinsMe = 0;
    int totalRoundWinsOpp = 0;

    for (var round in rounds) {
      for (var g in round) {
        totalMe += g.p1;
        totalOpp += g.p2;

        if (g.p1 >= controller.maxPoints) {
          totalPointsMe +=
              (controller.gschneidertDoppelt && g.gschneidertWinner == 1) ? 2 : 1;
        }
        if (g.p2 >= controller.maxPoints) {
          totalPointsOpp +=
              (controller.gschneidertDoppelt && g.gschneidertWinner == 2) ? 2 : 1;
        }
      }

      final winsMe =
          round.where((g) => g.p1 >= controller.maxPoints).length;
      final winsOpp =
          round.where((g) => g.p2 >= controller.maxPoints).length;

      if (winsMe > winsOpp) totalRoundWinsMe++;
      if (winsOpp > winsMe) totalRoundWinsOpp++;
    }

    final rows = <TableRow>[];
    rows.add(_buildHeaderRow(gamesPerRound));
    rows.addAll(_buildRoundRows(rounds, gamesPerRound));
    rows.addAll(_buildTotalRows(
      totalMe,
      totalOpp,
      totalPointsMe,
      totalPointsOpp,
      totalRoundWinsMe,
      totalRoundWinsOpp,
      gamesPerRound,
    ));

    return Table(
      border: TableBorder.all(color: Colors.blue.shade300, width: 2),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: rows,
    );
  }

  TableRow _buildHeaderRow(int gamesPerRound) {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blue.shade200),
      children: [
        _cell("Runde", bold: true, center: true),
        _cell("Team", bold: true, center: true),
        for (int i = 1; i <= gamesPerRound; i++)
          _cell("$i", bold: true, center: true),
        _cell("Gesamt", bold: true, center: true),
        _cell("Punkte", bold: true, center: true),
        _cell("Rundensieg", bold: true, center: true),
      ],
    );
  }

  List<TableRow> _buildRoundRows(List<List<GameState>> rounds, int gamesPerRound) {
    final List<TableRow> rows = [];

    final colorTeam1 = const Color(0xFFDCEBFF);
    final colorTeam2 = const Color(0xFFAFC8FF);

    for (int r = 0; r < rounds.length; r++) {
      final round = rounds[r];

      int sumMe = round.fold(0, (sum, g) => sum + g.p1);
      int sumOpp = round.fold(0, (sum, g) => sum + g.p2);

      int pointsMe = 0;
      int pointsOpp = 0;

      for (var g in round) {
        if (g.p1 >= controller.maxPoints) {
          pointsMe +=
              (controller.gschneidertDoppelt && g.gschneidertWinner == 1) ? 2 : 1;
        }
        if (g.p2 >= controller.maxPoints) {
          pointsOpp +=
              (controller.gschneidertDoppelt && g.gschneidertWinner == 2) ? 2 : 1;
        }
      }

      int roundWinMe = pointsMe > pointsOpp ? 1 : 0;
      int roundWinOpp = pointsOpp > pointsMe ? 1 : 0;

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: colorTeam1),
          children: [
            _cell("${r + 1}", center: true, bold: true),
            _cell(team1.isEmpty ? "Team 1" : team1, center: true, bold: true),
            for (int i = 0; i < gamesPerRound; i++)
              _cellGame(
                i < round.length ? "${round[i].p1}" : "",
                highlight: controller.gschneidertDoppelt &&
                    i < round.length &&
                    round[i].p1 == 0,
              ),
            _cell("$sumMe", center: true, bold: true),
            _cell("$pointsMe", center: true, bold: true),
            _cell("$roundWinMe", center: true, bold: true),
          ],
        ),
      );

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: colorTeam2),
          children: [
            _cell("", center: true),
            _cell(team2.isEmpty ? "Team 2" : team2, center: true, bold: true),
            for (int i = 0; i < gamesPerRound; i++)
              _cellGame(
                i < round.length ? "${round[i].p2}" : "",
                highlight: controller.gschneidertDoppelt &&
                    i < round.length &&
                    round[i].p2 == 0,
              ),
            _cell("$sumOpp", center: true, bold: true),
            _cell("$pointsOpp", center: true, bold: true),
            _cell("$roundWinOpp", center: true, bold: true),
          ],
        ),
      );
    }

    return rows;
  }

  List<TableRow> _buildTotalRows(
    int totalMe,
    int totalOpp,
    int totalPointsMe,
    int totalPointsOpp,
    int totalRoundWinsMe,
    int totalRoundWinsOpp,
    int gamesPerRound,
  ) {
    final base1 = const Color(0xFFDCEBFF);
    final base2 = const Color(0xFFAFC8FF);
    final winColor = const Color(0xCCB6F8C6);
    final loseColor = const Color(0xCCF8C6C6);
    final drawColor = const Color(0xCCFFF4C2);

    Color row1Color = base1;
    Color row2Color = base2;

    if (totalRoundWinsMe > totalRoundWinsOpp) {
      row1Color = winColor;
      row2Color = loseColor;
    } else if (totalRoundWinsOpp > totalRoundWinsMe) {
      row1Color = loseColor;
      row2Color = winColor;
    } else if (totalPointsMe > totalPointsOpp) {
      row1Color = winColor;
      row2Color = loseColor;
    } else if (totalPointsOpp > totalPointsMe) {
      row1Color = loseColor;
      row2Color = winColor;
    } else if (totalMe > totalOpp) {
      row1Color = winColor;
      row2Color = loseColor;
    } else if (totalOpp > totalMe) {
      row1Color = loseColor;
      row2Color = winColor;
    } else {
      row1Color = drawColor;
      row2Color = drawColor;
    }

    return [
      TableRow(
        decoration: BoxDecoration(color: row1Color),
        children: [
          _cell("Gesamt", center: true, bold: true),
          _cell(team1.isEmpty ? "Team 1" : team1, center: true, bold: true),
          for (int i = 0; i < gamesPerRound; i++) _cell(""),
          _cell("$totalMe", center: true, bold: true),
          _cell("$totalPointsMe", center: true, bold: true),
          _cell("$totalRoundWinsMe", center: true, bold: true),
        ],
      ),
      TableRow(
        decoration: BoxDecoration(color: row2Color),
        children: [
          _cell("", center: true),
          _cell(team2.isEmpty ? "Team 2" : team2, center: true, bold: true),
          for (int i = 0; i < gamesPerRound; i++) _cell(""),
          _cell("$totalOpp", center: true, bold: true),
          _cell("$totalPointsOpp", center: true, bold: true),
          _cell("$totalRoundWinsOpp", center: true, bold: true),
        ],
      ),
    ];
  }

  Widget _cell(String text, {bool bold = false, bool center = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontSize: 18,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _cellGame(String text, {bool highlight = false}) {
    return Container(
      color: highlight ? const Color(0x22FF0000) : Colors.transparent,
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }
}
