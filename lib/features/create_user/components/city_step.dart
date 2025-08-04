import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app/features/create_user/components/animated_step_container.dart';
import 'package:open_settings/open_settings.dart'; // Ajoute ce package dans ton pubspec.yaml

class CityStep extends StatefulWidget {
  final String? initialCity;
  final double? initialLat;
  final double? initialLon;
  final Function(String, double?, double?) onValidated;

  const CityStep({
    super.key,
    this.initialCity,
    this.initialLat,
    this.initialLon,
    required this.onValidated,
  });

  @override
  State<CityStep> createState() => _CityStepState();
}

class _CityStepState extends State<CityStep> {
  late TextEditingController _cityCtrl = TextEditingController(text: widget.initialCity ?? "");
  double? _latitude, _longitude;
  String? _error;
  bool _loadingLocation = false;
  bool _locationDeniedForever = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLat;
    _longitude = widget.initialLon;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_city, size: 42, color: colors.primary),
        const SizedBox(height: 14),
        const Text("Où veux-tu chercher un job ?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(
          "Indique ta ville ou utilise ta position",
          style: TextStyle(color: colors.onSurface.withOpacity(.7)),
        ),
        const SizedBox(height: 26),
        TextField(
          controller: _cityCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "Ville",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.location_city),
            errorText: _error,
          ),
          onSubmitted: (_) => _validate(),
        ),
        const SizedBox(height: 18),
        if (_latitude != null && _longitude != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.my_location, color: colors.primary, size: 20),
              const SizedBox(width: 6),
              Text(
                "Position détectée : lat. ${_latitude!.toStringAsFixed(4)}, lon. ${_longitude!.toStringAsFixed(4)}",
                style: TextStyle(fontSize: 13, color: colors.primary),
              ),
            ],
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: _loadingLocation
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: const Text("Me localiser"),
              onPressed: _loadingLocation ? null : _getLocation,
            ),
            if (_locationDeniedForever) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text("Ouvrir réglages"),
                onPressed: () => OpenSettings.openLocationSourceSetting(),
              ),
            ],
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: (_cityCtrl.text.trim().isNotEmpty || (_latitude != null && _longitude != null))
                ? _validate
                : null,
            child: const Text("Continuer"),
          ),
        ),
      ],
    );
  }

  Future<void> _getLocation() async {
    setState(() {
      _loadingLocation = true;
      _error = null;
      _locationDeniedForever = false;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw "La localisation est désactivée sur ton appareil.";

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Permission localisation refusée.";
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationDeniedForever = true;
          _error = "Permission localisation bloquée. Active-la dans les réglages de ton téléphone.";
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _cityCtrl.clear(); // Optionnel : laisse vide si position détectée
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = "Impossible de localiser : $e";
      });
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  void _validate() {
    final city = _cityCtrl.text.trim();
    if (city.isEmpty && (_latitude == null || _longitude == null)) {
      setState(() => _error = "Renseigne une ville ou ta position");
      return;
    }
    widget.onValidated(city, _latitude, _longitude);
  }
}