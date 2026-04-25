import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../services/access_service.dart';

/// Ecran affiche quand l'utilisateur connecte n'a pas (encore) acces a l'app
/// complete. Lui propose :
///  - de suivre le compte Instagram @whateka.ch (lien clickable)
///  - de saisir un code d'acces (WLMDY26 actuellement)
///
/// Si le code est correct, on persiste user_metadata.has_access = true
/// puis on enchaine avec un ecran "Bienvenue !" avant la map.
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AccessService _access = AccessService();
  bool _isValidating = false;
  String? _error;
  bool _shake = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _openInstagram() async {
    final url = Uri.parse('https://www.instagram.com/whateka.ch/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _validateCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _isValidating = true;
      _error = null;
    });
    final ok = await _access.tryUnlockWithCode(code);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed('/access_success');
    } else {
      setState(() {
        _isValidating = false;
        _error = S.current.maintenanceCodeIncorrect;
        _shake = true;
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _shake = false);
      });
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final s = S.of(context);
        return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.orange, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/home_icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    s.comingSoonTitle,
                    style: theme.textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.comingSoonDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.stone),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Bouton Instagram (gradient)
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openInstagram,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFA7E1E),
                                Color(0xFFD62976),
                                Color(0xFF962FBF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD62976).withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                s.maintenanceFollowOn,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '@whateka.ch',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Séparateur
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.line)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(s.maintenanceOrSeparator,
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.stone)),
                      ),
                      const Expanded(child: Divider(color: AppColors.line)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text(
                    s.maintenanceCodeLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.stone,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Champ code (animation shake si erreur)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    transform: Matrix4.translationValues(_shake ? -8 : 0, 0, 0),
                    child: TextField(
                      controller: _codeController,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 8,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                        TextInputFormatter.withFunction((old, neu) => TextEditingValue(
                              text: neu.text.toUpperCase(),
                              selection: neu.selection,
                            )),
                      ],
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        hintText: '••••••',
                        counterText: '',
                        errorText: _error,
                        hintStyle: const TextStyle(letterSpacing: 4, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValidating ? null : _validateCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isValidating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              s.maintenanceValidate,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: _signOut,
                    style: TextButton.styleFrom(foregroundColor: AppColors.stone),
                    child: Text(s.maintenanceLogout),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }
}

/// Ecran de succès après validation du code.
class AccessSuccessScreen extends StatefulWidget {
  const AccessSuccessScreen({super.key});

  @override
  State<AccessSuccessScreen> createState() => _AccessSuccessScreenState();
}

class _AccessSuccessScreenState extends State<AccessSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/map', (r) => false);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final theme = Theme.of(context);
        final s = S.of(context);
        return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 56),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              s.successWelcome,
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 240,
              child: Text(
                s.successDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.stone),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
