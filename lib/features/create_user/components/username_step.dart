// lib/onboarding/username_step.dart
import 'package:flutter/material.dart';

class UsernameStep extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onValidated;

  const UsernameStep({super.key, this.initialValue, required this.onValidated});

  @override
  State<UsernameStep> createState() => _UsernameStepState();
}

class _UsernameStepState extends State<UsernameStep> {
  late TextEditingController _controller = TextEditingController(text: widget.initialValue ?? "");
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Ton pseudo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 22),
        TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Pseudo",
            errorText: _error,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (v) => _validate(),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _validate,
            child: const Text("Continuer"),
          ),
        ),
      ],
    );
  }

  void _validate() {
    final value = _controller.text.trim();
    if (value.length < 3) {
      setState(() => _error = "Le pseudo doit faire au moins 3 lettres");
      return;
    }
    widget.onValidated(value);
  }
}