import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login.page.dart';

final _onboardingData = [
  {
    'image': 'assets/svg/onboarding1.svg',
    'title': "Réinvente ta recherche d’emploi",
    'subtitle': "Laisse notre IA te guider vers des opportunités invisibles ailleurs. Plus besoin de chercher, découvre.",
  },
  {
    'image': 'assets/svg/onboarding2.svg',
    'title': "Des offres sur-mesure pour toi",
    'subtitle': "Reçois des recommandations personnalisées qui évoluent avec ton parcours, tes compétences et tes ambitions.",
  },
  {
    'image': 'assets/svg/onboarding3.svg',
    'title': "Plus qu’un job, un avenir",
    'subtitle': "Notre tableau de bord intelligent maximise tes chances de succès. Ne rate plus jamais LA bonne opportunité.",
  },
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _current = 0;
  double _pageValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _pageValue = _controller.page ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton "Passer"
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToLogin(context),
                child: Text(
                  "Passer",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _onboardingData.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) {
                  final data = _onboardingData[i];
                  final isActive = (_pageValue.round() == i);
                  final double parallax = (_pageValue - i);

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Illustration SVG
                            Transform.translate(
                              offset: Offset(parallax * 50, 0),
                              child: Opacity(
                                opacity: 1.0 - parallax.abs().clamp(0, 1),
                                child: SvgPicture.asset(
                                  data['image']!,
                                  height: 220,
                                  colorFilter: ColorFilter.mode(
                                    colors.onBackground, // blanc en clair, blanc/gris en sombre
                                    BlendMode.srcIn,
                                  ),
                                )
                                    .animate(target: isActive ? 1 : 0)
                                    .fadeIn(duration: 500.ms)
                                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutBack, duration: 600.ms),
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Titre
                            Transform.translate(
                              offset: Offset(0, parallax * 30),
                              child: Opacity(
                                opacity: 1.0 - parallax.abs().clamp(0, 1),
                                child: Text(
                                  data['title']!,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onBackground,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                    .animate(target: isActive ? 1 : 0)
                                    .fadeIn(duration: 400.ms)
                                    .scaleXY(begin: 0.95, end: 1, duration: 550.ms),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Sous-titre
                            Transform.translate(
                              offset: Offset(0, parallax * 60),
                              child: Opacity(
                                opacity: 1.0 - parallax.abs().clamp(0, 1),
                                child: Text(
                                  data['subtitle']!,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colors.onSurface.withOpacity(0.7),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                    .animate(target: isActive ? 1 : 0)
                                    .fadeIn(delay: 120.ms, duration: 550.ms),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            _buildAnimatedIndicators(context),
            const SizedBox(height: 32),
            // Bouton bas (flottant ou rempli)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: AnimatedSwitcher(
                duration: 350.ms,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _current < _onboardingData.length - 1
                    ? FloatingActionButton(
                        key: const ValueKey('next'),
                        onPressed: () => _controller.nextPage(
                          duration: 500.ms,
                          curve: Curves.easeOutExpo,
                        ),
                        backgroundColor: colors.primary,
                        elevation: 2,
                        child: Icon(Icons.arrow_forward, color: colors.onPrimary),
                      )
                    : SizedBox(
                        key: const ValueKey('start'),
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _navigateToLogin(context),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                          ),
                          child: const Text("Commencer l'aventure"),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIndicators(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (i) {
          final isActive = _current == i;
          return AnimatedContainer(
            duration: 350.ms,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 32 : 10,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? colors.primary
                  : colors.onSurface.withOpacity(0.28),
              borderRadius: BorderRadius.circular(6),
            ),
            curve: Curves.elasticOut,
          );
        },
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: 600.ms,
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }
}