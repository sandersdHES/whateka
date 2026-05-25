import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/strings.dart';
import '../main.dart';

/// Section "Contactez-nous" affichee dans le profil. Deux options :
///   1. Bouton Instagram -> launch externe @whateka.ch
///   2. Bouton "Envoyer un message" -> dialog formulaire qui INSERT dans
///      public.contact_messages. L'admin voit le message sur la page
///      whateka-admin /messages.
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  static const String _instagramUrl = 'https://www.instagram.com/whateka.ch/';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.contactSectionTitle.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line, width: 0.5),
          ),
          child: Column(
            children: [
              _ContactRow(
                icon: Icons.photo_camera_outlined,
                iconBg: const Color(0xFFE1306C),
                title: s.contactInstagramButton,
                subtitle: s.contactInstagramSubtitle,
                onTap: () => _openInstagram(context),
              ),
              const Divider(height: 1, color: AppColors.line),
              _ContactRow(
                icon: Icons.mail_outline,
                iconBg: AppColors.cyan,
                title: s.contactMessageButton,
                subtitle: s.contactMessageSubtitle,
                onTap: () => _showMessageSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openInstagram(BuildContext context) async {
    try {
      await launchUrl(Uri.parse(_instagramUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir Instagram')),
      );
    }
  }

  Future<void> _showMessageSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const _ContactMessageSheet(),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.stone),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.stone),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactMessageSheet extends StatefulWidget {
  const _ContactMessageSheet();

  @override
  State<_ContactMessageSheet> createState() => _ContactMessageSheetState();
}

class _ContactMessageSheetState extends State<_ContactMessageSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      final email = user?.email;
      final name = user?.userMetadata?['first_name'] as String?;

      await supabase.from('contact_messages').insert({
        'user_id': user?.id,
        'sender_email': email,
        'sender_name': name,
        'subject': _subjectController.text.trim(),
        'message': _messageController.text.trim(),
        // status reste 'new' par defaut DB
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.contactSendSuccess),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.contactSendError),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mail_outline,
                        color: AppColors.cyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    s.contactDialogTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _subjectController,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: s.contactDialogSubject,
                  counterText: '',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '—' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLength: 2000,
                minLines: 5,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: s.contactDialogMessage,
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '—' : null,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.of(context).pop(),
                      child: Text(s.contactDialogCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _send,
                      icon: _busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send, size: 18),
                      label: Text(s.contactDialogSend),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
