import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../widgets/responsive_center.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final UserResponse res = await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: _passwordController.text.trim(),
        ),
      );

      if (mounted) {
        if (res.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe mis à jour avec succès'),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigate to dashboard or home, clearing stack
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/dashboard', (Route<dynamic> route) => false);
        }
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
            content: const Text('Une erreur est survenue'),
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nouveau mot de passe'),
      ),
      body: Stack(
        children: [
          // Background decorative elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.orange.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: ResponsiveCenter(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_reset,
                          size: 64, color: AppColors.cyan),
                      const SizedBox(height: 24),
                      Text(
                        'Définissez votre nouveau mot de passe',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.black.withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nouveau mot de passe',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (v) => (v != null && v.length >= 6)
                                      ? null
                                      : 'Min 6 caractères',
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirmer le mot de passe',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Requis';
                                    }
                                    if (v != _passwordController.text) {
                                      return 'Les mots de passe ne correspondent pas';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                if (_isLoading)
                                  const Center(
                                      child: CircularProgressIndicator())
                                else
                                  ElevatedButton(
                                    onPressed: _updatePassword,
                                    child: const Text('Mettre à jour'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
