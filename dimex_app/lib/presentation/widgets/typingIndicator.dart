import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: false);

    _animation = IntTween(begin: 1, end: 3).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _animation.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.secondary, // Make sure bgColor is defined or use a direct color value.
          child: Image.asset('assets/chatBot.png', fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Text(dots, style: const TextStyle(fontSize: 24, color: Colors.grey)),
      ],
    );
  }
}
