import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/features/auth/pages/widgets/logout_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
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
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', // Ou '/onboarding'
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo ou mascotte
                FlutterLogo(size: 84)
                    .animate()
                    .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.08, duration: 800.ms),
                const SizedBox(height: 32),
                Text(
                  "Bienvenue sur votre assistant IA d’emploi",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 600.ms),
                const SizedBox(height: 16),
                Text(
                  "Découvrez les opportunités, suivez vos candidatures, et profitez de recommandations sur mesure.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 220.ms, duration: 700.ms),
                const SizedBox(height: 40),

                // Actions principales (exemple)
                FilledButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Explorer les offres"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
                    textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    // Naviguer vers la page d’offres
                  },
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.dashboard_customize),
                  label: const Text("Tableau de bord"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    textStyle: theme.textTheme.titleMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    // Naviguer vers la page dashboard
                  },
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 32),
                // Autres infos, badges ou widgets ici…
              ],
            ),
          ),
        ),
      ),
    );
  }
}