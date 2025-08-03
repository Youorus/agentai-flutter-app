import 'package:flutter/material.dart';
import '../email_verification/services/email.verification.service.dart';


class EmailValidationPage extends StatefulWidget {
  final String email;
  const EmailValidationPage({super.key, required this.email});

  @override
  State<EmailValidationPage> createState() => _EmailValidationPageState();
}

class _EmailValidationPageState extends State<EmailValidationPage> {
  final codeCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _resent = false;
  bool _success = false;

  Future<void> _validateCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await VerificationEmailService.verifyEmailCode(
        email: widget.email,
        code: codeCtrl.text.trim(),
      );
      setState(() {
        _success = true;
      });
      // Ici tu peux naviguer ou afficher une page "succès"
      // Ex: Navigator.pushReplacement(...);
    } catch (e) {
      setState(() => _error = "Code invalide ou expiré");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _loading = true;
      _error = null;
      _resent = false;
    });
    try {
      await VerificationEmailService.sendValidationCode(widget.email);
      setState(() => _resent = true);
    } catch (e) {
      setState(() => _error = "Impossible de renvoyer le code.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    super.dispose();
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
          child: _success
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: colors.primary, size: 54),
                    const SizedBox(height: 24),
                    Text("Votre adresse e-mail est vérifiée !",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary)),
                    const SizedBox(height: 16),
                    const Text("Vous pouvez maintenant accéder à toutes les fonctionnalités."),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: () {
                        // Navigator.pushReplacement(....); // ta home page
                      },
                      child: const Text("Continuer"),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mark_email_unread_rounded, size: 48, color: colors.primary),
                    const SizedBox(height: 18),
                    Text(
                      "Un code à 5 chiffres a été envoyé à",
                      style: TextStyle(fontSize: 16, color: colors.onBackground),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.email,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.primary),
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
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _validateCode,
                        child: _loading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text("Valider mon compte"),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton.icon(
                      onPressed: _loading ? null : _resendCode,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(_resent ? "Code renvoyé !" : "Renvoyer le code"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}