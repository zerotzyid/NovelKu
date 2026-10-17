import 'package:flutter/material.dart';

class AIActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const AIActionButton({super.key, required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
    );
  }
}

class AIStreamingText extends StatelessWidget {
  final String text;
  final bool isComplete;
  const AIStreamingText({super.key, required this.text, this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green.shade50 : Colors.blue.shade50,
        border: Border.all(color: isComplete ? Colors.green : Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: isComplete ? Colors.green.shade900 : Colors.blue.shade900)),
    );
  }
}
