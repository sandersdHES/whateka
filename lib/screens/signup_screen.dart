import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../widgets/responsive_center.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'first_name': _firstnameController.text.trim()},
        emailRedirectTo: kIsWeb ? null : 'io.supabase.whateka://login-callback',
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/verification');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.current.error),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          backgroundColor: AppColors.paper,
          body: SafeArea(
            child: ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              s.signupTitle,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 36),

                            TextFormField(
                              controller: _firstnameController,
                              decoration: InputDecoration(
                                labelText: s.signupNamePlaceholder,
                                prefixIcon: const Icon(Icons.person_outline,
                                    size: 20),
                              ),
                              validator: (v) =>
                                  (v != null && v.isNotEmpty) ? null : 'Requis',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: s.loginEmailPlaceholder,
                                prefixIcon: const Icon(Icons.email_outlined,
                                    size: 20),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => (v != null && v.contains('@'))
                                  ? null
                                  : 'Email invalide',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: s.loginPasswordPlaceholder,
                                prefixIcon: const Icon(Icons.lock_outline,
                                    size: 20),
                              ),
                              obscureText: true,
                              validator: (v) => (v != null && v.length >= 6)
                                  ? null
                                  : 'Min 6 caractères',
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: s.signupConfirmPasswordPlaceholder,
                                prefixIcon: const Icon(Icons.lock_outline,
                                    size: 20),
                              ),
                              obscureText: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Requis';
                                if (v != _passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            if (_isLoading)
                              const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.cyan))
                            else
                              ElevatedButton(
                                onPressed: _signUp,
                                child: Text(s.btnSignup),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.signupHasAccount,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.stone),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.cyan,
                          ),
                          child: Text(
                            s.btnLogin,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
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
