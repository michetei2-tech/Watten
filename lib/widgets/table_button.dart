import 'package:flutter/material.dart';

class TableButton extends StatelessWidget {
  final int? table;
  final VoidCallback onTap;

  const TableButton({
    super.key,
    required this.table,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = table != null;

    return GestureDetector(
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
            table == null ? 'Tisch' : 'Tisch ${table!}',
            style: TextStyle(
              fontSize: 22,              // GROSSE ZAHLEN
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
