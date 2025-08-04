// lib/onboarding/job_alerts_step.dart
import 'package:flutter/material.dart';

class JobAlertsStep extends StatelessWidget {
  final bool? initialValue;
  final ValueChanged<bool> onValidated;

  const JobAlertsStep({super.key, this.initialValue, required this.onValidated});

  @override
  Widget build(BuildContext context) {
    bool value = initialValue ?? true;
    return StatefulBuilder(builder: (ctx, setState) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        const Text("Veux-tu recevoir des alertes d'emploi ?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 26),
        SwitchListTile(
          value: value,
          onChanged: (v) => setState(() => value = v),
          title: Text(value ? "Oui, je veux recevoir des alertes" : "Non, pas d'alerte"),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => onValidated(value),
            child: const Text("Terminer"),
          ),
        ),
      ]);
    });
  }
}