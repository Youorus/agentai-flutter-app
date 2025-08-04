import 'package:flutter/material.dart';

const statusOptions = [
  "Étudiant",
  "En recherche d'emploi",
  "En poste",
  "Freelance",
  "Salarié",
  "Autre"
];

class ProfessionalStatusStep extends StatefulWidget {
  final List<String>? initialStatuses;
  final ValueChanged<List<String>> onValidated;

  const ProfessionalStatusStep({
    super.key,
    this.initialStatuses,
    required this.onValidated,
  });

  @override
  State<ProfessionalStatusStep> createState() => _ProfessionalStatusStepState();
}

class _ProfessionalStatusStepState extends State<ProfessionalStatusStep> {
  late List<String> _statuses = List.from(widget.initialStatuses ?? []);
  String? _error;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Quel est ton statut actuel ?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: statusOptions.map((s) {
              return ChoiceChip(
                label: Text(s),
                selected: _statuses.contains(s),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _statuses.add(s);
                    } else {
                      _statuses.remove(s);
                    }
                    _error = null;
                  });
                },
                labelStyle: TextStyle(
                  color: _statuses.contains(s) ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _statuses.contains(s)
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400]!,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              );
            }).toList(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_statuses.isEmpty) {
                  setState(() => _error = "Sélectionne au moins un statut");
                  return;
                }
                widget.onValidated(_statuses);
              },
              child: const Text("Continuer"),
            ),
          ),
        ],
      ),
    );
  }
}