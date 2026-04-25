import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../widgets/responsive_center.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        // Apres connexion : passage par le splash qui affiche le logo 3s
        // puis fade sur 1s avant de debarquer l'utilisateur sur la carte.
        Navigator.pushReplacementNamed(context, '/splash');
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                              s.loginTitle,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 40),

                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: s.loginEmailPlaceholder,
                                prefixIcon: const Icon(Icons.email_outlined,
                                    size: 20),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Requis'
                                  : null,
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
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Requis'
                                  : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, '/forgot_password'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.cyan,
                                ),
                                child: Text(s.loginForgotPassword),
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (_isLoading)
                              const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.cyan))
                            else
                              ElevatedButton(
                                onPressed: _signIn,
                                child: Text(s.btnLogin),
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
                          s.loginNoAccount,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.stone),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, '/signup'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.cyan,
                          ),
                          child: Text(
                            s.btnSignup,
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
