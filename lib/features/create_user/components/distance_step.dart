import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as Math;

class DistanceStep extends StatefulWidget {
  final double? initialDistance;
  final double? cityLat;
  final double? cityLon;
  final void Function(double) onValidated;

  const DistanceStep({
    super.key,
    this.initialDistance,
    this.cityLat,
    this.cityLon,
    required this.onValidated,
  });

  @override
  State<DistanceStep> createState() => _DistanceStepState();
}

class _DistanceStepState extends State<DistanceStep> {
  double _distance = 20;
  final TextEditingController _controller = TextEditingController();
  List<String>? _citiesInRadius;
  bool _loadingCities = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialDistance != null) {
      _distance = widget.initialDistance!;
    }
    _controller.text = _distance.round().toString();
    _fetchCitiesInRadiusIfPossible(_distance);
  }

  void _onSliderChanged(double value) {
    setState(() {
      _distance = value;
      _controller.text = value.round().toString();
    });
    _fetchCitiesInRadiusIfPossible(value);
  }

  void _onInputChanged(String value) {
    final n = double.tryParse(value);
    if (n != null && n >= 1 && n <= 200) {
      setState(() {
        _distance = n;
      });
      _fetchCitiesInRadiusIfPossible(n);
    }
  }

  void _fetchCitiesInRadiusIfPossible(double distanceKm) {
    if (widget.cityLat != null && widget.cityLon != null) {
      _fetchCitiesInRadius(widget.cityLat!, widget.cityLon!, distanceKm);
    }
  }

  Future<void> _fetchCitiesInRadius(double lat, double lon, double distanceKm) async {
    setState(() {
      _loadingCities = true;
      _citiesInRadius = null;
    });
    try {
      // Remplace l'URL par celle de ton backend ou API géo
      final url = Uri.parse('https://ton-api.com/cities-in-radius?lat=$lat&lon=$lon&radius=$distanceKm');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        setState(() => _citiesInRadius = List<String>.from(data["cities"]));
      } else {
        setState(() => _citiesInRadius = []);
      }
    } catch (e) {
      setState(() => _citiesInRadius = []);
    } finally {
      setState(() => _loadingCities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCoord = widget.cityLat != null && widget.cityLon != null;
    final LatLng cityCenter = LatLng(widget.cityLat ?? 48.8566, widget.cityLon ?? 2.3522); // Paris par défaut

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "À quelle distance maximale ?",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Tu recevras des offres dans ce rayon autour de la ville sélectionnée.",
          style: TextStyle(fontSize: 16, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // MAP & CERCLE
        if (hasCoord)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  center: cityCenter,
                  zoom: _getZoomForRadius(_distance),
                  interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.app',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: cityCenter,
                        color: Colors.blue.withOpacity(0.18),
                        borderStrokeWidth: 1.5,
                        borderColor: Colors.blue.withOpacity(0.5),
                        radius: _kmToPixelRadius(_distance, cityCenter, _getZoomForRadius(_distance)),
                      ),
                    ],
                  ),
                 MarkerLayer(
  markers: [
    Marker(
      width: 34,
      height: 34,
      point: cityCenter,
      child: const Icon(Icons.location_on, color: Colors.red, size: 34),
    ),
  ],
),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Slider(
                value: _distance,
                min: 1,
                max: 200,
                divisions: 199,
                label: "${_distance.round()} km",
                onChanged: _onSliderChanged,
              ),
            ),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                onChanged: _onInputChanged,
                decoration: const InputDecoration(
                  suffixText: "km",
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        if (hasCoord)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _loadingCities
                ? const Center(child: CircularProgressIndicator())
                : (_citiesInRadius != null && _citiesInRadius!.isNotEmpty)
                    ? Text(
                        "Ce rayon inclut aussi : ${_citiesInRadius!.join(', ')}",
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                        textAlign: TextAlign.center,
                      )
                    : (_citiesInRadius != null && _citiesInRadius!.isEmpty)
                        ? const Text(
                            "Aucune autre ville détectée dans ce rayon.",
                            style: TextStyle(color: Colors.black54, fontSize: 13),
                          )
                        : const SizedBox.shrink(),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => widget.onValidated(_distance),
          child: const Text("Continuer"),
        ),
      ],
    );
  }

  // Calcule le zoom optimal selon la distance
  double _getZoomForRadius(double km) {
    if (km < 3) return 12.5;
    if (km < 10) return 11;
    if (km < 30) return 10;
    if (km < 70) return 9;
    if (km < 120) return 8;
    return 7.2;
  }

  // Rayon (en pixels) du cercle pour flutter_map
  double _kmToPixelRadius(double km, LatLng center, double zoom) {
    return (km * 1000) / _metersPerPixel(center.latitude, zoom);
  }

  double _metersPerPixel(double lat, double zoom) {
    // Calcul OpenStreetMap
    final earthCircumference = 40075016.686;
    return earthCircumference * Math.cos(lat * Math.pi / 180) / (256 * Math.pow(2, zoom));
  }
}