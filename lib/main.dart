import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // si tu as configuré flutterfire configure
import 'app.dart';
import 'firebase_options.dart';

/// Initialise Flutter, la localisation et Firebase
Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  try {
    // Si tu as firebase_options.dart, préfère cette ligne :
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    debugPrint("✅ Firebase initialisé");
  } catch (e, st) {
    debugPrint("❌ Erreur Firebase: $e\n$st");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}