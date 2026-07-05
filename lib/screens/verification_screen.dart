import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';

/// Écran affiché après l'inscription, en attente de confirmation d'e-mail (#2).
///
/// Sur le même appareil, quand l'utilisateur clique le lien de confirmation,
/// le deep link (mobile) ou la détection d'URL (web) établit la session :
/// `supabase_flutter` émet alors `onAuthStateChange` avec une session non nulle.
/// On écoute cet événement pendant que l'écran est visible pour enchaîner
/// automatiquement dans l'app, au lieu de laisser l'utilisateur bloqué ici.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      // Une session apparaît = e-mail confirmé -> on entre dans l'app.
      if (data.session != null && mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/splash', (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(s.verificationTitle)),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_read,
                      size: 80, color: AppColors.cyan),
                  const SizedBox(height: 24),
                  Text(
                    s.verificationHeading,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.ink,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.verificationDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.stone,
                        ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(s.verificationBackToLogin),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
