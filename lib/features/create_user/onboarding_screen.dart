import 'package:flutter/material.dart';
import 'package:app/features/create_user/components/animated_step_container.dart';
import 'package:app/features/create_user/components/city_step.dart';
import 'package:app/features/create_user/components/job_alerts_step.dart';
import 'package:app/features/create_user/components/job_titles_step.dart';
import 'package:app/features/create_user/components/professional_status_step.dart';
import 'package:app/features/create_user/components/contract_types_step.dart';
import 'package:app/features/create_user/components/industries_step.dart';
import 'package:app/features/create_user/components/username_step.dart';
import 'package:app/features/create_user/models/user_profile.dart';
import 'package:app/features/create_user/services/user_profile.service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final UserProfile _profile = UserProfile(username: "");

  bool _loading = false;
  String? _error;

  Future<void> _saveField(String field, dynamic value) async {
    setState(() => _loading = true);
    try {
      await UserProfileService.patchProfileField(field, value);
      setState(() => _error = null);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _nextStep([dynamic value]) async {
    if (_loading) return;
    switch (_step) {
      case 0:
        await _saveField('username', value);
        setState(() => _profile.username = value);
        break;
      case 1:
        final city = value[0] as String?;
        final lat = value[1] as double?;
        final lon = value[2] as double?;
        await _saveField('city', city);
        await _saveField('latitude', lat);
        await _saveField('longitude', lon);
        setState(() {
          _profile.city = city;
          _profile.latitude = lat;
          _profile.longitude = lon;
        });
        break;
      case 2:
        await _saveField('industries', value);
        setState(() => _profile.industries = value);
        break;
      case 3:
        await _saveField('professional_status', value); // <-- Liste !
        setState(() => _profile.professionalStatus = value);
        break;
      case 4:
        await _saveField('job_titles', value);
        setState(() => _profile.jobTitles = value);
        break;
      case 5:
        await _saveField('contract_types', value);
        setState(() => _profile.contractTypes = value);
        break;
      case 6:
        await _saveField('job_alerts_active', value);
        setState(() => _profile.jobAlertsActive = value);
        Navigator.of(context).pushReplacementNamed('/home');
        return;
    }
    setState(() {
      _step++;
      _error = null;
    });
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_step) {
      case 0:
        content = UsernameStep(
          initialValue: _profile.username,
          onValidated: _nextStep,
        );
        break;
      case 1:
        content = CityStep(
          initialCity: _profile.city,
          initialLat: _profile.latitude,
          initialLon: _profile.longitude,
          onValidated: (city, lat, lon) => _nextStep([city, lat, lon]),
        );
        break;
      case 2:
        content = IndustriesStep(
          initialIndustries: _profile.industries,
          onValidated: _nextStep,
        );
        break;
      case 3:
        content = ProfessionalStatusStep(
          initialStatuses: _profile.professionalStatus, // <- List<String>
          onValidated: _nextStep,
        );
        break;
      case 4:
        content = JobTitlesStep(
          initialTitles: _profile.jobTitles,
          selectedSecteurs: _profile.industries,
          onValidated: _nextStep,
        );
        break;
      case 5:
        content = ContractTypesStep(
          initialTypes: _profile.contractTypes,
          onValidated: _nextStep,
        );
        break;
      case 6:
        content = JobAlertsStep(
          initialValue: _profile.jobAlertsActive,
          onValidated: _nextStep,
        );
        break;
      default:
        content = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 18),
              const Text("Profil complété !", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                child: const Text("Accéder à mon tableau de bord"),
              ),
            ],
          ),
        );
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedStepContainer(child: content),
            if (_loading)
              Container(
                color: Colors.black.withOpacity(.05),
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (_error != null)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.red[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ),
            if (_step > 0)
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevStep,
                  tooltip: "Revenir à l'étape précédente",
                  splashRadius: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}