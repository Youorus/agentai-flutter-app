import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler pour messages en arrière-plan.
/// DOIT être une fonction globale.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Si besoin: initialize Firebase ici (si non fait par default isolate).
  // await Firebase.initializeApp();

  // Vous pouvez logguer / prétraiter, ou planifier un fetch silencieux ici.
}

class AppNotificationService {
  AppNotificationService._();
  static final AppNotificationService instance = AppNotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  /// Identifiants de canal Android
  static const AndroidNotificationChannel _offerChannel = AndroidNotificationChannel(
    'offer_channel',
    'Nouvelles offres',
    description: 'Notifications des offres matchées',
    importance: Importance.high,
  );

  /// Initialisation globale (à appeler dans main())
  Future<void> init({required Function(String offerId) onSelectOffer}) async {
    // Permissions iOS / Android 13+
    await _requestPermissions();

    // Créer le canal Android
    await _createAndroidChannel();

    // Initialiser FLN (pour foreground)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload != null && payload.isNotEmpty) {
          onSelectOffer(payload);
        }
      },
    );

    // Handlers Firebase
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground: par défaut Android n’affiche pas, on montre via FLN
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final n = message.notification;
      final data = message.data;

      // Afficher localement uniquement si la notif système n’est pas déjà affichée
      // (iOS affiche aussi en foreground si autorisation "provisional" non utilisée)
      if (n != null) {
        await _fln.show(
          _uniqueIdFromMessage(message),
          n.title ?? 'Nouvelle offre',
          n.body ?? 'Découvre vite dans l’app !',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _offerChannel.id,
              _offerChannel.name,
              channelDescription: _offerChannel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: data['offer_id']?.toString(),
        );
      }
    });

    // Tap quand l’app est en background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final offerId = message.data['offer_id']?.toString();
      if (offerId != null) onSelectOffer(offerId);
    });

    // Tap quand l’app était tuée (cold start)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      final offerId = initialMessage.data['offer_id']?.toString();
      if (offerId != null) {
        // Petit délai pour laisser le router se monter
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onSelectOffer(offerId);
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _fcm.requestPermission(
        alert: true, badge: true, sound: true,
        provisional: false, // mets true si tu veux des "quiet" notifs par défaut
      );
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );
    } else {
      // Android 13+: la lib gère la permission automatiquement quand nécessaire.
    }
  }

  Future<void> _createAndroidChannel() async {
    final android = _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(_offerChannel);
    }
  }

  /// Récupère le token FCM (à envoyer à ton backend)
  Future<String?> getToken() => _fcm.getToken();

  /// Bonne pratique : s’abonner à un topic personnel (ex: user_123)
  Future<void> subscribeUserTopic(String userId) => _fcm.subscribeToTopic('user_$userId');

  int _uniqueIdFromMessage(RemoteMessage m) {
    final id = m.data['offer_id'] ?? m.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    // Hash simple
    return id.hashCode & 0x7fffffff;
  }
}