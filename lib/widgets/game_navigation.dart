import 'package:flutter/material.dart';

class GameNavigation extends StatelessWidget {
  final int current;
  final bool canGoNext;
  final bool canGoPrev;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const GameNavigation({
    super.key,
    required this.current,
    required this.canGoNext,
    required this.canGoPrev,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canGoPrev ? onPrev : null,
          icon: const Icon(Icons.arrow_left),
          iconSize: 36,
        ),
        Text(
          'Spiel ${current + 1} / 5',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: canGoNext ? onNext : null,
          icon: const Icon(Icons.arrow_right),
          iconSize: 36,
        ),
      ],
    );
  }
}
