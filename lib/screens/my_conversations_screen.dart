import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../widgets/responsive_center.dart';
import 'conversation_thread_screen.dart';

/// Liste des conversations user <-> equipe Whateka.
/// Chaque ligne = un contact_messages (thread).
class MyConversationsScreen extends StatefulWidget {
  const MyConversationsScreen({super.key});

  @override
  State<MyConversationsScreen> createState() => _MyConversationsScreenState();
}

class _MyConversationsScreenState extends State<MyConversationsScreen> {
  late Future<List<_Conversation>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_Conversation>> _load() async {
    final supa = Supabase.instance.client;
    final user = supa.auth.currentUser;
    if (user == null) return [];

    // 1. Threads de l'user
    final List<dynamic> threadsRaw = await supa
        .from('contact_messages')
        .select('id, subject, message, status, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    if (threadsRaw.isEmpty) return [];

    final ids = threadsRaw.map((t) => t['id'] as int).toList();

    // 2. Pour chaque thread, on recupere :
    //    - la derniere reponse (date + role)
    //    - le nombre de messages total (1 + replies)
    final List<dynamic> repliesRaw = await supa
        .from('contact_message_replies')
        .select('contact_message_id, author_role, created_at, message')
        .inFilter('contact_message_id', ids)
        .order('created_at', ascending: false);

    final lastReplyByThread = <int, Map<String, dynamic>>{};
    final repliesCountByThread = <int, int>{};
    for (final r in repliesRaw) {
      final tid = r['contact_message_id'] as int;
      repliesCountByThread[tid] = (repliesCountByThread[tid] ?? 0) + 1;
      lastReplyByThread.putIfAbsent(tid, () => r as Map<String, dynamic>);
    }

    return threadsRaw.map((t) {
      final id = t['id'] as int;
      final lastReply = lastReplyByThread[id];
      final isUnreadFromAdmin =
          lastReply != null && lastReply['author_role'] == 'admin';
      return _Conversation(
        id: id,
        subject: t['subject'] as String,
        firstMessage: t['message'] as String,
        createdAt: DateTime.parse(t['created_at'] as String),
        lastActivityAt: lastReply != null
            ? DateTime.parse(lastReply['created_at'] as String)
            : DateTime.parse(t['created_at'] as String),
        lastSnippet: (lastReply != null
                ? lastReply['message'] as String
                : t['message'] as String)
            .replaceAll('\n', ' '),
        lastFromAdmin: isUnreadFromAdmin,
        repliesCount: repliesCountByThread[id] ?? 0,
      );
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
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
            title: Text(s.contactConversationsTitle),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: FutureBuilder<List<_Conversation>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.cyan));
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forum_outlined,
                            size: 56, color: AppColors.stone.withValues(alpha: 0.6)),
                        const SizedBox(height: 16),
                        Text(s.contactMyMessagesEmpty,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(s.contactMyMessagesEmptyHint,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.stone),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              }
              return ResponsiveCenter(
                maxWidth: 560,
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _ConversationRow(
                      conv: list[i],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ConversationThreadScreen(
                              contactMessageId: list[i].id,
                              subject: list[i].subject,
                            ),
                          ),
                        );
                        // Refresh la liste apres retour du thread
                        // (au cas ou un message a ete envoye)
                        if (mounted) _refresh();
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Conversation {
  final int id;
  final String subject;
  final String firstMessage;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final String lastSnippet;
  final bool lastFromAdmin;
  final int repliesCount;

  _Conversation({
    required this.id,
    required this.subject,
    required this.firstMessage,
    required this.createdAt,
    required this.lastActivityAt,
    required this.lastSnippet,
    required this.lastFromAdmin,
    required this.repliesCount,
  });
}

class _ConversationRow extends StatelessWidget {
  final _Conversation conv;
  final VoidCallback onTap;
  const _ConversationRow({required this.conv, required this.onTap});

  String _fmtRelative(BuildContext context, DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}a';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 0) return '${diff.inDays}j';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}min';
    return 'maint.';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: conv.lastFromAdmin
                  ? AppColors.cyan.withValues(alpha: 0.5)
                  : AppColors.line,
              width: conv.lastFromAdmin ? 1.5 : 0.5,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: conv.lastFromAdmin
                      ? AppColors.cyan
                      : AppColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  conv.lastFromAdmin
                      ? Icons.mark_email_unread_outlined
                      : Icons.forum_outlined,
                  color: conv.lastFromAdmin ? Colors.white : AppColors.cyan,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.subject,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _fmtRelative(context, conv.lastActivityAt),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.stone),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conv.lastSnippet,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.stone,
                            fontWeight: conv.lastFromAdmin
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (conv.repliesCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${conv.repliesCount + 1} messages',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.stone,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.stone),
            ],
          ),
        ),
      ),
    );
  }
}
