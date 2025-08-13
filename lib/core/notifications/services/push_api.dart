// services/push_api.dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/core/utils/api_client.dart';
import 'dart:convert';

class PushApi {
  PushApi._();

  static Future<void> syncCurrentToken({String? deviceId}) async {
    final fm = FirebaseMessaging.instance;

    // iOS : demander la permission AVANT tout
    if (Platform.isIOS) {
      final settings = await fm.requestPermission(
        alert: true, badge: true, sound: true, provisional: false,
      );
      // Présentation en foreground (iOS)
      await fm.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      // Attendre l’APNs token (petite boucle avec timeout)
      String? apns;
      for (int i = 0; i < 25; i++) { // ~5s max
        apns = await fm.getAPNSToken();
        if (apns != null) break;
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (apns == null) {
        // Sur simulateur iOS, on arrive ici: pas d’APNs token → pas de FCM token fiable
        // Log et quitte sans erreur.
        // debugPrint("[Push] APNs token indisponible (simulateur ?). Skip register.");
        return;
      }
    }

    // Ici, on peut récupérer le FCM token (iOS/Android)
    final fcmToken = await fm.getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    final platform = Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web');
    final payload = {
      'token': fcmToken,
      'platform': platform,
      if (deviceId != null) 'device_id': deviceId,
    };

    final resp = await ApiClient().post(
      "/me/fcm-token",
      auth: true,
      body: payload,
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 204) {
      // Gère proprement l’erreur si besoin
      // throw parseApiError(resp);
    }

    // Reste en écoute des refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (newToken.isEmpty) return;
      await ApiClient().post(
        "/me/fcm-token",
        auth: true,
        body: {
          'token': newToken,
          'platform': platform,
          if (deviceId != null) 'device_id': deviceId,
        },
        headers: {'Content-Type': 'application/json'},
      );
    });
  }
}