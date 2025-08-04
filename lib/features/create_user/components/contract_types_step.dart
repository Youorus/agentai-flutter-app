// lib/onboarding/contract_types_step.dart
import 'package:flutter/material.dart';

const contractTypes = [
  "CDI", "CDD", "Alternance", "Stage", "Freelance", "Apprentissage"
];

class ContractTypesStep extends StatefulWidget {
  final List<String>? initialTypes;
  final ValueChanged<List<String>> onValidated;

  const ContractTypesStep({super.key, this.initialTypes, required this.onValidated});

  @override
  State<ContractTypesStep> createState() => _ContractTypesStepState();
}

class _ContractTypesStepState extends State<ContractTypesStep> {
  late List<String> _selected = List.from(widget.initialTypes ?? []);
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text("Types de contrat souhaités", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 18),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: contractTypes.map((type) => ChoiceChip(
          label: Text(type),
          selected: _selected.contains(type),
          onSelected: (v) {
            setState(() {
              v ? _selected.add(type) : _selected.remove(type);
            });
          },
        )).toList(),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            if (_selected.isEmpty) {
              setState(() => _error = "Sélectionne au moins un type");
              return;
            }
            widget.onValidated(_selected);
          },
          child: const Text("Continuer"),
        ),
      ),
    ]);
  }
}