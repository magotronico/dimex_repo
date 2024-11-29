import 'package:flutter/material.dart';

class PercentageCard extends StatelessWidget {
  final String label;
  final dynamic value;

  const PercentageCard({
    Key? key,
    required this.label,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${value ?? '0'}%', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
