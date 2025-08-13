import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:open_settings/open_settings.dart';
import 'dart:convert';

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

  List<Map<String, dynamic>> _citySuggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.initialLat;
    _longitude = widget.initialLon;
    if (_cityCtrl.text.isNotEmpty) {
      _fetchCitySuggestions(_cityCtrl.text, fillFirst: true);
    }
  }

  Future<void> _getLocationAndFillCity() async {
    setState(() {
      _loadingLocation = true;
      _error = null;
      _locationDeniedForever = false;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw "La localisation est désactivée sur ton appareil.";
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw "Permission localisation refusée.";
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationDeniedForever = true;
          _error = "Permission localisation bloquée. Active-la dans les réglages de ton téléphone.";
        });
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();
      // Call reverse geocoding API
      final result = await _reverseGeocode(pos.latitude, pos.longitude);
      if (result != null) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
          _cityCtrl.text = result['city'] ?? result['name'] ?? '';
          _error = null;
        });
      } else {
        setState(() {
          _error = "Impossible d'obtenir la ville à partir de votre position.";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Impossible de localiser : $e";
      });
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  // Appel API Nominatim (ou ton propre backend si RGPD)
  Future<Map<String, dynamic>?> _reverseGeocode(double lat, double lon) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon&accept-language=fr');
    final resp = await http.get(url, headers: {"User-Agent": "TonApp/1.0"});
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      // On tente de trouver le nom de la ville dans l'objet address
      final address = data['address'] ?? {};
      final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'];
      return {
        'city': city,
        'name': data['display_name'],
        'lat': lat,
        'lon': lon,
      };
    }
    return null;
  }

  Future<void> _fetchCitySuggestions(String pattern, {bool fillFirst = false}) async {
    setState(() => _isSearching = true);
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?city=${Uri.encodeComponent(pattern)}&format=jsonv2&accept-language=fr&countrycodes=fr&limit=5');
    final resp = await http.get(url, headers: {"User-Agent": "TonApp/1.0"});
    if (resp.statusCode == 200) {
      final results = json.decode(resp.body) as List;
      setState(() {
        _citySuggestions = results.map((item) {
          final displayName = item['display_name'];
          final lat = double.tryParse(item['lat'] ?? "");
          final lon = double.tryParse(item['lon'] ?? "");
          return {
            'label': displayName,
            'city': (item['address']?['city'] ?? item['address']?['town'] ?? item['address']?['village'] ?? displayName),
            'lat': lat,
            'lon': lon,
          };
        }).toList();
        if (fillFirst && _citySuggestions.isNotEmpty) {
          // Auto-remplit city et lat/lon si initialCity connu
          _latitude = _citySuggestions.first['lat'];
          _longitude = _citySuggestions.first['lon'];
        }
      });
    }
    setState(() => _isSearching = false);
  }

  void _onCitySelected(Map<String, dynamic> city) {
    setState(() {
      _cityCtrl.text = city['city'] ?? city['label'];
      _latitude = city['lat'];
      _longitude = city['lon'];
      _citySuggestions = [];
    });
  }

  void _validate() {
    final city = _cityCtrl.text.trim();
    if (city.isEmpty || _latitude == null || _longitude == null) {
      setState(() => _error = "Choisis une ville dans la liste ou utilise la localisation");
      return;
    }
    widget.onValidated(city, _latitude, _longitude);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, size: 44, color: colors.primary),
        const SizedBox(height: 12),
        const Text(
          "Où veux-tu chercher un job ?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          "Recherche dans une ville ou autour de ta position",
          style: TextStyle(color: colors.onSurface.withOpacity(.7)),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _cityCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "Ville",
            hintText: "Commence à taper pour suggérer...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
            errorText: _error,
          ),
          onChanged: (value) {
            if (value.length >= 2) _fetchCitySuggestions(value);
          },
          onSubmitted: (_) {
            if (_citySuggestions.isNotEmpty) _onCitySelected(_citySuggestions.first);
            else _validate();
          },
        ),
        if (_citySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              border: Border.all(color: colors.primary.withOpacity(.2)),
              borderRadius: BorderRadius.circular(12),
              color: colors.surfaceVariant.withOpacity(.95),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _citySuggestions.length,
              itemBuilder: (context, i) {
                final city = _citySuggestions[i];
                return ListTile(
                  title: Text(city['label']),
                  onTap: () => _onCitySelected(city),
                );
              },
            ),
          ),
        if (_latitude != null && _longitude != null && _cityCtrl.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.my_location, color: colors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  "Coordonnées : lat. ${_latitude!.toStringAsFixed(4)}, lon. ${_longitude!.toStringAsFixed(4)}",
                  style: TextStyle(fontSize: 13, color: colors.primary),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              icon: _loadingLocation
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
              label: const Text("Me localiser"),
              onPressed: _loadingLocation ? null : _getLocationAndFillCity,
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
            onPressed: (_cityCtrl.text.trim().isNotEmpty && _latitude != null && _longitude != null)
                ? _validate
                : null,
            child: const Text("Continuer"),
          ),
        ),
      ],
    );
  }
}