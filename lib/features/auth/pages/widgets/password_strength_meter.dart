import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  int _score(String value) {
    int score = 0;
    if (value.length >= 6) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[a-z]').hasMatch(value)) score++;
    if (value.length >= 10) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final score = _score(password);

    String label;
    Color color;
    switch (score) {
      case 0:
      case 1:
        label = "Faible";
        color = Colors.red;
        break;
      case 2:
        label = "Moyen";
        color = Colors.orange;
        break;
      case 3:
      case 4:
        label = "Fort";
        color = Colors.lightGreen;
        break;
      default:
        label = "Excellent";
        color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: score / 5,
          color: color,
          backgroundColor: color.withOpacity(0.2),
          minHeight: 7,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 6),
        Text(
          "Sécurité du mot de passe : $label",
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}