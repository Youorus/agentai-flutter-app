import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth.services.dart';
import '../models/user.dart';
import '/core/utils/token_storage.dart';
import 'widgets/social_button.dart';
import 'widgets/password_strength_meter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:app/features/home/pages/home.page.dart';
import 'login.page.dart';
import '../../email_verification/pages/email.verification.page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;

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

  void _validatePass() {
    setState(() {
      passTouched = true;
      final value = passCtrl.text;
      if (value.isEmpty) {
        passError = "Veuillez entrer un mot de passe";
      } else if (value.length < 6) {
        passError = "6 caractères minimum";
      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
        passError = "Ajoutez une majuscule";
      } else if (!RegExp(r'[0-9]').hasMatch(value)) {
        passError = "Ajoutez un chiffre";
      } else {
        passError = null;
      }
    });
  }

  bool get canSubmit =>
      emailError == null &&
      passError == null &&
      emailTouched &&
      passTouched &&
      !_loading;

  // --- Redirection centrale après inscription, Google ou Facebook ---
  void _redirectToEmailValidation(String email) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EmailValidationPage(),
      ),
    );
  }

  // --- Inscription avec Google ---
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) return setState(() => _loading = false);
      final auth = await account.authentication;
      final token = await AuthApi.googleSignIn(idToken: auth.idToken!);
      await TokenStorage.saveToken(token.accessToken);
      // RÉDIRECT TO EMAIL VALIDATION AVEC EMAIL GOOGLE
      _redirectToEmailValidation(token.email);
    } catch (e) {
      debugPrint("[GoogleSignIn] Exception: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur Google : ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  // --- Inscription avec Facebook ---
  Future<void> _signInWithFacebook() async {
    setState(() => _loading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      debugPrint("[FacebookSignIn] Status: ${result.status}, Message: ${result.message}");

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        final userData = await FacebookAuth.instance.getUserData();
        final token = await AuthApi.facebookSignIn(accessToken: accessToken);
        await TokenStorage.saveToken(token.accessToken);
        // On redirige toujours vers validation email avec l'email Facebook
        final email = token.email ?? userData['email'] ?? "${userData['id']}@facebook.com";
        _redirectToEmailValidation(email);
      } else if (result.status == LoginStatus.cancelled) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connexion Facebook annulée.")),
          );
        }
      } else {
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
      setState(() => _loading = false);
    }
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    setState(() {
      emailTouched = true;
      passTouched = true;
    });
    if (!canSubmit) return;
    setState(() => _loading = true);

    try {
      final token = await AuthApi.signup(
        UserCreate(
          email: emailCtrl.text.trim(),
          password: passCtrl.text,
        ),
      );
      await TokenStorage.saveToken(token.accessToken);
      _redirectToEmailValidation(token.email); // <-- On utilise email du token
    } catch (e) {
      debugPrint("[Signup] Exception: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.toString()}"),
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

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Inscription',
          style: TextStyle(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: colors.onBackground),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    Image.asset('assets/logo.png', height: 48),
                    const SizedBox(height: 22),
                    Text(
                      "Créer un compte",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onBackground,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // --- Champ email ---
                    TextFormField(
                      controller: emailCtrl,
                      enabled: !_loading,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        labelText: "Adresse e-mail",
                        hintText: "votre@email.com",
                        labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.4)),
                        prefixIcon: Icon(Icons.mail_outlined, color: colors.onSurface.withOpacity(0.3)),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        errorText: emailTouched ? emailError : null,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (_) => _validateEmail(),
                      validator: (_) => emailTouched ? emailError : null,
                      onTap: () => setState(() => emailTouched = true),
                    ),
                    const SizedBox(height: 18),
                    // --- Champ mot de passe ---
                    TextFormField(
                      controller: passCtrl,
                      enabled: !_loading,
                      obscureText: _obscure,
                      style: TextStyle(color: colors.onSurface),
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        hintText: "••••••••",
                        labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
                        hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.4)),
                        prefixIcon: Icon(Icons.lock_outline, color: colors.onSurface.withOpacity(0.3)),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        errorText: passTouched ? passError : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                            color: colors.onSurface.withOpacity(0.5),
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSignup(),
                      onChanged: (_) => _validatePass(),
                      validator: (_) => passTouched ? passError : null,
                      onTap: () => setState(() => passTouched = true),
                    ),
                    if (passCtrl.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: PasswordStrengthMeter(password: passCtrl.text),
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: canSubmit ? _handleSignup : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 1,
                          shadowColor: colors.primary.withOpacity(0.18),
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
                                "Créer mon compte",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: Divider(color: colors.outline.withOpacity(0.2))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text("ou", style: TextStyle(color: colors.onSurface.withOpacity(0.6))),
                        ),
                        Expanded(child: Divider(color: colors.outline.withOpacity(0.2))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // --- Boutons sociaux ---
                    SocialButton(
                      text: "Continuer avec Google",
                      iconAsset: 'assets/svg/google_icon.svg',
                      backgroundColor: colors.surface,
                      borderColor: Colors.transparent,
                      textColor: colors.onSurface,
                      onPressed: _loading ? null : _signInWithGoogle,
                    ),
                    const SizedBox(height: 12),
                    SocialButton(
                      text: "Continuer avec Facebook",
                      iconAsset: 'assets/svg/facebook_icon.svg',
                      backgroundColor: colors.surface,
                      borderColor: Colors.transparent,
                      textColor: colors.onSurface,
                      onPressed: _loading ? null : _signInWithFacebook,
                    ),
                    // --- Apple plus tard
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Déjà un compte ? ", style: TextStyle(color: colors.onSurface.withOpacity(0.7))),
                        GestureDetector(
                          onTap: _loading
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context).pushReplacement(
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 400),
                                      pageBuilder: (_, __, ___) => const LoginPage(),
                                      transitionsBuilder: (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.1),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "En continuant, vous acceptez nos Conditions d'utilisation\net notre Politique de confidentialité.",
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.4),
                        fontSize: 11,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
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