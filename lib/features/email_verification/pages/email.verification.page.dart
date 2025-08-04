import 'package:flutter/material.dart';
import '../services/email.verification.service.dart';

class EmailValidationPage extends StatefulWidget {
  const EmailValidationPage({super.key});

  @override
  State<EmailValidationPage> createState() => _EmailValidationPageState();
}

class _EmailValidationPageState extends State<EmailValidationPage> {
  final codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _successMsg;

  Future<void> _validateCode() async {
    setState(() {
      _loading = true;
      _error = null;
      _successMsg = null;
    });
    try {
      await VerificationEmailService.verifyEmailCode(code: codeCtrl.text);
      setState(() => _successMsg = "Compte validé !");
      // Redirige vers la Home page après quelques secondes
      await Future.delayed(const Duration(seconds: 2));
       if (mounted) {
      Navigator.of(context).pushReplacementNamed('/onboarding_form');
    }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _loading = true;
      _error = null;
      _successMsg = null;
    });
    try {
      await VerificationEmailService.resendEmailCode();
      setState(() => _successMsg = "Nouveau code envoyé !");
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation de l\'email'),
        centerTitle: true,
        backgroundColor: colors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mark_email_unread_rounded, size: 52, color: colors.primary),
                const SizedBox(height: 18),
                Text(
                  "Un code à 5 chiffres a été envoyé à votre adresse email.",
                  style: TextStyle(fontSize: 16, color: colors.onBackground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: codeCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: InputDecoration(
                    labelText: "Code de validation",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: _error,
                    counterText: "",
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                if (_successMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(_successMsg!, style: const TextStyle(color: Colors.green)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _validateCode,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text("Valider mon compte"),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading ? null : _resendCode,
                  child: const Text("Renvoyer le code"),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vérifie tes spams si tu ne reçois rien sous 1 minute.",
                  style: TextStyle(color: colors.onSurface.withOpacity(0.6), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}