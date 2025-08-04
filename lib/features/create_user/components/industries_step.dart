import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/features/create_user/models/secteur_emploi.dart';

class IndustriesStep extends StatefulWidget {
  final List<String>? initialIndustries;
  final ValueChanged<List<String>> onValidated;

  const IndustriesStep({
    super.key,
    this.initialIndustries,
    required this.onValidated,
  });

  @override
  State<IndustriesStep> createState() => _IndustriesStepState();
}

class _IndustriesStepState extends State<IndustriesStep> {
  List<SecteurEmploi> _secteurs = [];
  late List<String> _selected = List.from(widget.initialIndustries ?? []);
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSecteurs();
  }

  Future<void> _loadSecteurs() async {
    try {
      final str = await rootBundle.loadString('assets/data/mots_cles_emplois_france.json');
      final data = jsonDecode(str)['secteurs_et_mots_cles'] as List;
      setState(() {
        _secteurs = data.map((j) => SecteurEmploi.fromJson(j)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Erreur chargement secteurs : $e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Dans quels secteurs ?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: _secteurs.map((s) => ChoiceChip(
              label: Text(s.secteur, textAlign: TextAlign.center),
              selected: _selected.contains(s.secteur),
              onSelected: (v) {
                setState(() {
                  v ? _selected.add(s.secteur) : _selected.remove(s.secteur);
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              labelStyle: TextStyle(
                color: _selected.contains(s.secteur)
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: _selected.contains(s.secteur) ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: _selected.contains(s.secteur)
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                ),
              ),
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
                  setState(() => _error = "Sélectionne au moins un secteur");
                  return;
                }
                widget.onValidated(_selected);
              },
              child: const Text("Continuer"),
            ),
          ),
        ],
      ),
    );
  }
}