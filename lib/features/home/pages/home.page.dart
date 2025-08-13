import 'package:flutter/material.dart';
import '/features/home/models/offer.dart';
import '/features/home/components/OfferCard.dart';
import '/features/auth/pages/widgets/logout_button.dart';
import '/features/home/services/offer_match_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Offer> offers = [];
  final _notification = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotification();
    _fetchMatches();
    // Polling toutes les 30s (ou adapte intervalle)
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      await _fetchMatches();
      return mounted;
    });
  }

  Future<void> _initNotification() async {
    // === Demande la permission iOS
    final iosPlugin = _notification
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
    }

    // === Initialisation cross-platforme
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _notification.initialize(initializationSettings);
  }

  Future<void> _fetchMatches() async {
    try {
      final newOffers = await OfferMatchService.getMyMatchedOffers();
      // Détecter les nouvelles offres
      final newIds = newOffers.map((o) => o.id).toSet();
      final oldIds = offers.map((o) => o.id).toSet();
      final added = newIds.difference(oldIds);

      if (added.isNotEmpty) {
        for (final id in added) {
          final offer = newOffers.firstWhere((o) => o.id == id);
          _showNotificationForOffer(offer);
        }
      }
      setState(() {
        offers = newOffers;
      });
    } catch (e) {
      print("Erreur lors du chargement des offres matchées : $e");
      // Tu peux afficher un snackbar/erreur utilisateur si besoin
    }
  }

  Future<void> _showNotificationForOffer(Offer offer) async {
    // Notification Android
    const android = AndroidNotificationDetails(
      'offer_channel',
      'Nouvelles offres',
      channelDescription: 'Notification pour offres matchées',
      importance: Importance.max,
      priority: Priority.high,
    );
    // Notification iOS
    const ios = DarwinNotificationDetails();

    const notifDetails = NotificationDetails(android: android, iOS: ios);

    await _notification.show(
      offer.id, // unique ID
      'Nouvelle offre pour toi : ${offer.title}',
      offer.companyDescription ?? offer.secteur ?? 'Découvre vite dans l’appli !',
      notifDetails,
      payload: offer.id.toString(),
    );
  }

  // === TEST NOTIF ===
  void _testNotification() {
    final testOffer = Offer(
      id: DateTime.now().millisecondsSinceEpoch % 100000, // id unique à chaque test
      source: "Test",
      url: "https://test",
      title: "Test Notification Offre",
      companyDescription: "Cette notification est un test.",
      location: "Paris",
      latitude: 0.0,
      longitude: 0.0,
      publishedAt: "2025-08-08",
      contractType: "CDI",
      description: "Ceci est un test de notification.",
      secteur: "Tech",
    );
    _showNotificationForOffer(testOffer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil"),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: null,
        automaticallyImplyLeading: false,
        actions: [
          LogoutButton(
            onLogout: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMatches,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            return OfferCard(offer: offers[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testNotification,
        tooltip: 'Tester notification',
        child: const Icon(Icons.notifications_active),
      ),
    );
  }
}