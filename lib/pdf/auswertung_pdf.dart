import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../logic/score_controller.dart';
import '../models/game_state.dart';

class AuswertungPdf {
  final ScoreController controller;
  final String team1;
  final String team2;

  AuswertungPdf({
    required this.controller,
    required this.team1,
    required this.team2,
  });

  Future<Uint8List> build(PdfPageFormat format) async {
    final pdf = pw.Document();

    final currentRound = controller.games;

    final List<List<GameState>> rounds = [
      if (currentRound.any((g) => g.p1 != 0 || g.p2 != 0)) currentRound,
      ...controller.allRounds,
    ];

    final int totalGames = controller.gamesPerRound;
    final int blockSize = 10;
    final int blocks = (totalGames / blockSize).ceil();

    final now = DateTime.now();
    final datum = "${now.day}.${now.month}.${now.year}";
    final zeit =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final headerColor = PdfColors.blue300;
    final team1Color = PdfColor.fromInt(0xFFDCEBFF);
    final team2Color = PdfColor.fromInt(0xFFAFC8FF);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Seite ${context.pageNumber} / ${context.pagesCount}",
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Auswertung – $team1 vs $team2",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  "Erstellt am $datum um $zeit",
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.SizedBox(height: 16),
              ],
            ),
          );

          for (int blockIndex = 0; blockIndex < blocks; blockIndex++) {
            final int startGame = blockIndex * blockSize;
            final int endGame =
                (startGame + blockSize).clamp(0, totalGames);

            widgets.add(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (blocks > 1)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 4),
                      child: pw.Text(
                        "Spiele ${startGame + 1}–$endGame",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.blueGrey, width: 1),
                    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                    children: _buildPdfTableBlock(
                      rounds: rounds,
                      startGame: startGame,
                      endGame: endGame,
                      headerColor: headerColor,
                      team1Color: team1Color,
                      team2Color: team2Color,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  List<pw.TableRow> _buildPdfTableBlock({
    required List<List<GameState>> rounds,
    required int startGame,
    required int endGame,
    required PdfColor headerColor,
    required PdfColor team1Color,
    required PdfColor team2Color,
  }) {
    final rows = <pw.TableRow>[];

    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: headerColor),
        children: [
          _header("Runde"),
          _header("Team"),
          for (int i = startGame; i < endGame; i++) _header("${i + 1}"),
          _header("Gesamt"),
          _header("Punkte"),
          _header("Rundensieg"),
        ],
      ),
    );

    int totalMe = 0;
    int totalOpp = 0;
    int totalPointsMe = 0;
    int totalPointsOpp = 0;
    int totalRoundWinsMe = 0;
    int totalRoundWinsOpp = 0;

    for (int r = 0; r < rounds.length; r++) {
      final round = rounds[r];

      int sumMe = 0;
      int sumOpp = 0;
      int pointsMe = 0;
      int pointsOpp = 0;

      for (var g in round) {
        sumMe += g.p1;
        sumOpp += g.p2;

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

      totalMe += sumMe;
      totalOpp += sumOpp;
      totalPointsMe += pointsMe;
      totalPointsOpp += pointsOpp;
      totalRoundWinsMe += roundWinMe;
      totalRoundWinsOpp += roundWinOpp;

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: team1Color),
          children: [
            _cell("${r + 1}", bold: true),
            _cell(team1.isEmpty ? "Team 1" : team1, bold: true),
            for (int i = startGame; i < endGame; i++)
              _cell(
                i < round.length ? "${round[i].p1}" : "",
                highlight: controller.gschneidertDoppelt &&
                    i < round.length &&
                    round[i].p1 == 0,
              ),
            _cell("$sumMe", bold: true),
            _cell("$pointsMe", bold: true),
            _cell("$roundWinMe", bold: true),
          ],
        ),
      );

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: team2Color),
          children: [
            _cell(""),
            _cell(team2.isEmpty ? "Team 2" : team2, bold: true),
            for (int i = startGame; i < endGame; i++)
              _cell(
                i < round.length ? "${round[i].p2}" : "",
                highlight: controller.gschneidertDoppelt &&
                    i < round.length &&
                    round[i].p2 == 0,
              ),
            _cell("$sumOpp", bold: true),
            _cell("$pointsOpp", bold: true),
            _cell("$roundWinOpp", bold: true),
          ],
        ),
      );
    }

    rows.addAll(_buildTotals(
      totalMe,
      totalOpp,
      totalPointsMe,
      totalPointsOpp,
      totalRoundWinsMe,
      totalRoundWinsOpp,
      startGame,
      endGame,
    ));

    return rows;
  }

  List<pw.TableRow> _buildTotals(
    int totalMe,
    int totalOpp,
    int totalPointsMe,
    int totalPointsOpp,
    int totalRoundWinsMe,
    int totalRoundWinsOpp,
    int startGame,
    int endGame,
  ) {
    final base1 = PdfColor.fromInt(0xFFDCEBFF);
    final base2 = PdfColor.fromInt(0xFFAFC8FF);
    final winColor = PdfColor.fromInt(0xCCB6F8C6);
    final loseColor = PdfColor.fromInt(0xCCF8C6C6);
    final drawColor = PdfColor.fromInt(0xCCFFF4C2);

    PdfColor row1Color = base1;
    PdfColor row2Color = base2;

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
      pw.TableRow(
        decoration: pw.BoxDecoration(color: row1Color),
        children: [
          _cell("Gesamt", bold: true),
          _cell(team1.isEmpty ? "Team 1" : team1, bold: true),
          for (int i = startGame; i < endGame; i++) _cell(""),
          _cell("$totalMe", bold: true),
          _cell("$totalPointsMe", bold: true),
          _cell("$totalRoundWinsMe", bold: true),
        ],
      ),
      pw.TableRow(
        decoration: pw.BoxDecoration(color: row2Color),
        children: [
          _cell(""),
          _cell(team2.isEmpty ? "Team 2" : team2, bold: true),
          for (int i = startGame; i < endGame; i++) _cell(""),
          _cell("$totalOpp", bold: true),
          _cell("$totalPointsOpp", bold: true),
          _cell("$totalRoundWinsOpp", bold: true),
        ],
      ),
    ];
  }

  pw.Widget _header(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _cell(
    String text, {
    bool bold = false,
    bool highlight = false,
  }) {
    return pw.Container(
      color: highlight ? PdfColor.fromInt(0x22FF0000) : null,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
