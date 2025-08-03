import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth.services.dart'; // AuthApi, gestion API backend
import '../models/token.dart';
import '/core/utils/token_storage.dart';
import 'package:app/features/home/pages/home.page.dart';
import 'signup.page.dart';
import 'widgets/social_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;

  // Gestion UX des erreurs de saisie
  String? emailError;
  String? passError;
  bool emailTouched = false;
  bool passTouched = false;

  @override
  void initState() {
    super.initState();
    emailCtrl.addListener(_validateEmail);
    passCtrl.addListener(_validatePass);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // Validation e-mail (simple regex)
  void _validateEmail() {
    setState(() {
      emailTouched = true;
      final value = emailCtrl.text;
      final regex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");
      if (value.isEmpty) {
        emailError = "Veuillez entrer votre email";
      } else if (!regex.hasMatch(value)) {
        emailError = "Adresse e-mail invalide";
      } else {
        emailError = null;
      }
    });
  }

  // Validation mot de passe
  void _validatePass() {
    setState(() {
      passTouched = true;
      final value = passCtrl.text;
      if (value.isEmpty) {
        passError = "Veuillez entrer votre mot de passe";
      } else if (value.length < 6) {
        passError = "Le mot de passe doit contenir au moins 6 caractères";
      } else {
        passError = null;
      }
    });
  }

  // Bouton "Se connecter" activable si tout est validé
  bool get canSubmit =>
      emailError == null &&
      passError == null &&
      emailTouched &&
      passTouched &&
      !_loading;

  // Connexion Google
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return; // Utilisateur a annulé
      }

      final auth = await account.authentication;
      final token = await AuthApi.googleSignIn(idToken: auth.idToken!);
      await TokenStorage.saveToken(token.accessToken);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      debugPrint("[GoogleSignIn] Exception: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Text("Erreur Google : ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Connexion Facebook
  Future<void> _signInWithFacebook() async {
    setState(() => _loading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      debugPrint("[FacebookSignIn] Status: ${result.status}, Message: ${result.message}");

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        debugPrint("[FacebookSignIn] AccessToken: $accessToken");

        final token = await AuthApi.facebookSignIn(accessToken: accessToken);
        await TokenStorage.saveToken(token.accessToken);

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        debugPrint("[FacebookSignIn] Connexion annulée");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connexion Facebook annulée.")),
          );
        }
      } else {
        debugPrint("[FacebookSignIn] Erreur: ${result.message}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Connexion Facebook échouée : ${result.message}"),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("[FacebookSignIn] Exception: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur Facebook: ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Connexion classique (email + mot de passe)
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    setState(() {
      emailTouched = true;
      passTouched = true;
    });
    if (!canSubmit) return;
    setState(() => _loading = true);

    try {
      final token = await AuthApi.login(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );
      await TokenStorage.saveToken(token.accessToken);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      debugPrint("[Login] Exception: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text("Échec de connexion : ${e.toString()}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Connexion',
          style: TextStyle(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Logo de ton app
                    Image.asset('assets/logo.png', height: 42)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .scale(),
                    const SizedBox(height: 16),
                    Text(
                      "Connecte-toi à ton espace",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 24),
                    // Champ email
                    TextFormField(
                      controller: emailCtrl,
                      enabled: !_loading,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        labelText: "Adresse e-mail",
                        hintText: "votre@email.com",
                        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                        labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.8)),
                        prefixIcon: Icon(Icons.email_outlined, color: colors.onSurface.withOpacity(0.7)),
                        filled: true,
                        fillColor: isDark ? colors.surface : colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        errorText: emailTouched ? emailError : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (_) => _validateEmail(),
                      validator: (_) => emailTouched ? emailError : null,
                      onTap: () {
                        setState(() => emailTouched = true);
                      },
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 16),
                    // Champ mot de passe
                    TextFormField(
                      controller: passCtrl,
                      enabled: !_loading,
                      obscureText: _obscure,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        hintText: "••••••••",
                        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                        labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.8)),
                        prefixIcon: Icon(Icons.lock_outline, color: colors.onSurface.withOpacity(0.7)),
                        filled: true,
                        fillColor: isDark ? colors.surface : colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        errorText: passTouched ? passError : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      onChanged: (_) => _validatePass(),
                      validator: (_) => passTouched ? passError : null,
                      onTap: () {
                        setState(() => passTouched = true);
                      },
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 24),
                    // Bouton de connexion principal
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: canSubmit ? _handleLogin : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: colors.primary.withOpacity(0.3),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Se connecter",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ).animate().fadeIn(delay: 600.ms),
                    ),
                    const SizedBox(height: 24),
                    // Séparateur
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: colors.outline.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "ou",
                            style: TextStyle(
                              color: colors.onSurface.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: colors.outline.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 24),
                    // === Boutons sociaux Google & Facebook ===
                    SocialButton(
                      text: "Continuer avec Google",
                      iconAsset: 'assets/svg/google_icon.svg',
                      backgroundColor: colors.onPrimary,
                      borderColor: colors.outline.withOpacity(0.2),
                      textColor: colors.onSurface,
                      onPressed: _signInWithGoogle,
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: 16),
                    SocialButton(
                      text: "Continuer avec Facebook",
                      iconAsset: 'assets/svg/facebook_icon.svg',
                      backgroundColor: colors.onPrimary,
                      borderColor: colors.outline.withOpacity(0.2),
                      textColor: colors.onSurface,
                      onPressed: _signInWithFacebook,
                    ).animate().fadeIn(delay: 900.ms),
                    const SizedBox(height: 32),
                    // Lien vers inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Pas encore de compte ? ",
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _loading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 500),
                                      pageBuilder: (_, __, ___) => const SignupPage(),
                                      transitionsBuilder: (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.1),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            )),
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Text(
                              "S'inscrire",
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 1.1.seconds),
                    const SizedBox(height: 32),
                    // Disclaimer bas de page
                    Text(
                      "En continuant, vous acceptez nos Conditions d'utilisation\net notre Politique de confidentialité.",
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.5),
                        fontSize: 12,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 1.2.seconds),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}