import 'package:flutter/material.dart';

class TextDetails extends StatelessWidget {
  final String label; // The key part (e.g., "Tasa de Interés:")
  final String value; // The value part (e.g., "5%")

  const TextDetails({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ', // Key part
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          TextSpan(
            text: value.isNotEmpty ? value : 'No information', // Value part
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}
