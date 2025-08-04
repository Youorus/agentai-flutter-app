import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/features/create_user/models/secteur_emploi.dart';

class JobTitlesStep extends StatefulWidget {
  final List<String>? initialTitles;
  final List<String>? selectedSecteurs;
  final ValueChanged<List<String>> onValidated;

  const JobTitlesStep({
    super.key,
    this.initialTitles,
    required this.onValidated,
    this.selectedSecteurs,
  });

  @override
  State<JobTitlesStep> createState() => _JobTitlesStepState();
}

class _JobTitlesStepState extends State<JobTitlesStep> {
  List<SecteurEmploi> _secteurs = [];
  late List<String> _selected = List.from(widget.initialTitles ?? []);
  List<String> _suggestions = [];
  String? _error;
  bool _loading = true;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSecteurs();
  }

  Future<void> _loadSecteurs() async {
    try {
      final str = await rootBundle.loadString('assets/data/mots_cles_emplois_france.json');
      final data = jsonDecode(str)['secteurs_et_mots_cles'] as List;
      _secteurs = data.map((j) => SecteurEmploi.fromJson(j)).toList();

      // Suggestions : mots-clés du/les secteurs sélectionnés
      _suggestions = [];
      if (widget.selectedSecteurs != null && widget.selectedSecteurs!.isNotEmpty) {
        for (final secteur in widget.selectedSecteurs!) {
          final s = _secteurs.firstWhere(
            (se) => se.secteur == secteur,
            orElse: () => SecteurEmploi(secteur: secteur, motsCles: []),
          );
          _suggestions.addAll(s.motsCles);
        }
      } else {
        // Tous les mots-clés si pas de secteur sélectionné
        for (final s in _secteurs) {
          _suggestions.addAll(s.motsCles);
        }
      }
      _suggestions = _suggestions.toSet().toList(); // unicité
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = "Erreur chargement métiers : $e";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    // Les suggestions qui ne sont PAS déjà sélectionnées
    final availableSuggestions = _suggestions.where((s) => !_selected.contains(s)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Quels métiers t'intéressent ?",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          // Affichage des mots-clés suggérés (bulles à cocher)
          if (availableSuggestions.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableSuggestions.map((motCle) {
                return ChoiceChip(
                  label: Text(motCle),
                  selected: _selected.contains(motCle),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selected.add(motCle);
                        _error = null;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 18),
          // Affichage des métiers sélectionnés (bulles supprimables)
          if (_selected.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _selected.map((t) => Chip(
                label: Text(t),
                onDeleted: () => setState(() => _selected.remove(t)),
              )).toList(),
            ),
          const SizedBox(height: 16),
          // Autocomplete pour ajout personnalisé
          Autocomplete<String>(
            optionsBuilder: (txt) {
              if (txt.text.isEmpty) return const Iterable<String>.empty();
              return _suggestions.where((s) =>
                  s.toLowerCase().contains(txt.text.toLowerCase()) &&
                  !_selected.contains(s));
            },
            fieldViewBuilder: (ctx, ctrl, focus, onSubmitted) => TextField(
              controller: _ctrl,
              focusNode: focus,
              decoration: InputDecoration(
                labelText: "Ajoute un métier personnalisé",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _addTitle(_ctrl.text),
            ),
            onSelected: (v) => _addTitle(v),
            optionsViewBuilder: (context, onSelect, options) {
              final showCustom = _ctrl.text.isNotEmpty && !_suggestions.contains(_ctrl.text.trim()) && !_selected.contains(_ctrl.text.trim());
              final opts = options.toList();
              if (showCustom) opts.insert(0, _ctrl.text.trim());

              return Material(
                elevation: 4,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: opts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(opts[index]),
                      onTap: () => onSelect(opts[index]),
                    );
                  },
                  shrinkWrap: true,
                ),
              );
            },
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_selected.isEmpty) {
                  setState(() => _error = "Ajoute au moins un métier");
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

  void _addTitle(String value) {
    final v = value.trim();
    if (v.isNotEmpty && !_selected.contains(v)) {
      setState(() {
        _selected.add(v);
        _ctrl.clear();
        _error = null;
      });
    }
  }
}