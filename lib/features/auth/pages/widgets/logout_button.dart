import 'package:flutter/material.dart';
import '/core/utils/api_client.dart';
import '/core/utils/token_storage.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback? onLogout;

  const LogoutButton({super.key, this.onLogout});

  Future<void> _logout(BuildContext context) async {
    try {
      await ApiClient().get("/logout");
    } catch (_) {
      // Silent fail
    }
    await TokenStorage.deleteToken();

    // Affiche la SnackBar, puis redirige après un court délai
    final snackBar = SnackBar(
      content: const Text(
        "Déconnexion réussie",
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.green[600],
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(milliseconds: 900), // rapide !
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Redirection après 700ms
    Future.delayed(const Duration(milliseconds: 700), () {
      // Ferme toutes les pages précédentes (remonte à la racine)
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', // Ou '/onboarding'
        (route) => false,
      );
      // Si callback onLogout (pour tracking/analytics)
      if (onLogout != null) onLogout!();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout_rounded),
      tooltip: "Se déconnecter",
      onPressed: () => _logout(context),
    );
  }
}