import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../widgets/responsive_center.dart';

/// Vue thread "chat" entre l'utilisateur et l'equipe Whateka.
/// Affiche : message initial + N reponses (bulles user a droite, admin
/// a gauche), avec composer en bas pour repondre.
class ConversationThreadScreen extends StatefulWidget {
  final int contactMessageId;
  final String subject;

  const ConversationThreadScreen({
    super.key,
    required this.contactMessageId,
    required this.subject,
  });

  @override
  State<ConversationThreadScreen> createState() =>
      _ConversationThreadScreenState();
}

class _ConversationThreadScreenState extends State<ConversationThreadScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _loading = true;
  List<_Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final supa = Supabase.instance.client;
    try {
      // Message initial
      final initial = await supa
          .from('contact_messages')
          .select('sender_name, sender_email, message, created_at')
          .eq('id', widget.contactMessageId)
          .maybeSingle();
      final replies = await supa
          .from('contact_message_replies')
          .select('author_role, author_name, author_email, message, created_at')
          .eq('contact_message_id', widget.contactMessageId)
          .order('created_at', ascending: true);

      final bubbles = <_Bubble>[];
      if (initial != null) {
        bubbles.add(_Bubble(
          isAdmin: false,
          author: (initial['sender_name'] as String?) ??
              (initial['sender_email'] as String?) ??
              'Vous',
          message: initial['message'] as String,
          createdAt: DateTime.parse(initial['created_at'] as String),
        ));
      }
      for (final r in (replies as List)) {
        bubbles.add(_Bubble(
          isAdmin: r['author_role'] == 'admin',
          author: (r['author_name'] as String?) ??
              (r['author_email'] as String?) ??
              (r['author_role'] == 'admin' ? 'Équipe Whateka' : 'Vous'),
          message: r['message'] as String,
          createdAt: DateTime.parse(r['created_at'] as String),
        ));
      }

      if (!mounted) return;
      setState(() {
        _bubbles = bubbles;
        _loading = false;
      });
      // Scroll en bas apres render
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);

    final supa = Supabase.instance.client;
    final user = supa.auth.currentUser;
    try {
      await supa.from('contact_message_replies').insert({
        'contact_message_id': widget.contactMessageId,
        'author_role': 'user',
        'author_user_id': user?.id,
        'author_email': user?.email,
        'author_name': user?.userMetadata?['first_name'] as String?,
        'message': text,
      });

      if (!mounted) return;
      _replyController.clear();
      // Re-fetch pour afficher la nouvelle bulle
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.contactThreadReplySuccess),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.current.contactThreadReplyError),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            surfaceTintColor: AppColors.surface,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  s.contactThreadTeamLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.stone),
                ),
              ],
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.cyan))
                    : ResponsiveCenter(
                        maxWidth: 560,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: _bubbles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, i) => _BubbleWidget(b: _bubbles[i]),
                        ),
                      ),
              ),
              // Composer
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.line),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  12 + MediaQuery.of(context).viewInsets.bottom * 0,
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 2000,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: s.contactThreadReplyPlaceholder,
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  const BorderSide(color: AppColors.line),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: AppColors.cyan,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _sending ? null : _send,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: _sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send,
                                    color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bubble {
  final bool isAdmin;
  final String author;
  final String message;
  final DateTime createdAt;
  _Bubble({
    required this.isAdmin,
    required this.author,
    required this.message,
    required this.createdAt,
  });
}

class _BubbleWidget extends StatelessWidget {
  final _Bubble b;
  const _BubbleWidget({required this.b});

  String _fmtHm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isAdmin = b.isAdmin;
    return Row(
      mainAxisAlignment:
          isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                isAdmin ? s.contactThreadTeamLabel : b.author,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.stone,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isAdmin
                      ? AppColors.line.withValues(alpha: 0.6)
                      : AppColors.cyan,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isAdmin ? 4 : 18),
                    bottomRight: Radius.circular(isAdmin ? 18 : 4),
                  ),
                ),
                child: Text(
                  b.message,
                  style: TextStyle(
                    color: isAdmin ? AppColors.ink : Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _fmtHm(b.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.stone,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
