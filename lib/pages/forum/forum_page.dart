import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/bloc/forum/threads_bloc.dart';
import 'package:frontend/bloc/forum/threads_event.dart';
import 'package:frontend/bloc/forum/threads_state.dart';
import 'package:frontend/dto/request/create_thread_request_dto.dart';
import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/pages/forum/thread_detail_page.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/bloc/auth/auth_state.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/utils/time_ago.dart';
import 'package:frontend/bloc/user_profile/user_profile_bloc.dart';
import 'package:frontend/bloc/user_profile/user_profile_event.dart';
import 'package:frontend/bloc/user_profile/user_profile_state.dart';
import 'package:frontend/model/role.dart';
import 'package:frontend/services/search_service.dart';
import 'package:frontend/config/injection_container.dart';

class ForumPage extends HookWidget {
  const ForumPage({super.key, required this.content});
  final ContentResponseDto content;

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final bodyController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    // Cache for creator verification status across rebuilds
    final verifiedMap = useState<Map<String, bool>>({});
    final fetching = useState<Set<String>>({});

    // Ensure threads are loaded when entering the page
    useEffect(() {
      context.read<ThreadsBloc>().add(LoadThreads(contentId: content.id));
      final authState = context.read<AuthBloc>().state;
      final upState = context.read<UserProfileBloc>().state;
      if (authState is AuthSuccess && upState is! UserProfileLoaded) {
        context.read<UserProfileBloc>().add(LoadUserProfile());
      }
      return null;
    }, [content.id]);

    return BlocListener<ThreadsBloc, ThreadsState>(
        listenWhen: (prev, next) => next is ThreadsLoaded && next.currentOperation != null,
        listener: (context, state) {
          if (!context.mounted) return;
          if (state is ThreadsLoaded && state.currentOperation != null) {
            final op = state.currentOperation!;
            if (!op.isLoading && op.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(op.message!)),
              );
              Navigator.of(context, rootNavigator: true).maybePop();
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text('${content.title} • Forum')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthSuccess) {
                final go = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Login required'),
                    content: const Text('You need to login to create a thread.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Login')),
                    ],
                  ),
                );
                if (!context.mounted) return;
                if (go == true) {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                  );
                }
                if (!context.mounted) return;
                if (context.read<AuthBloc>().state is! AuthSuccess) return; // still not logged in
              }
              await showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                      title: const Text('Start a new thread'),
                      content: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(labelText: 'Title'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Title is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: bodyController,
                              maxLines: 5,
                              decoration: const InputDecoration(labelText: 'Body'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Body is required'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                        BlocBuilder<ThreadsBloc, ThreadsState>(
                          builder: (context, state) {
                            final isLoading = state is ThreadsLoaded && state.currentOperation?.isLoading == true;
                            return FilledButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;
                                      final bloc = context.read<ThreadsBloc>();
                                      // Wait for next non-loading operation result
                                      final next = bloc.stream.firstWhere((s) =>
                                          s is ThreadsLoaded && s.currentOperation != null && !s.currentOperation!.isLoading);
                                      bloc.add(
                                        CreateThread(
                                          contentId: content.id,
                                          request: CreateThreadRequestDto(
                                            title: titleController.text.trim(),
                                            body: bodyController.text.trim(),
                                          ),
                                        ),
                                      );
                                      final stateAfter = await next;
                                      if (!context.mounted) return;
                                      if (stateAfter is ThreadsLoaded && stateAfter.currentOperation != null) {
                                        // Close dialog and show feedback
                                        Navigator.of(context, rootNavigator: true).pop();
                                        final msg = stateAfter.currentOperation!.message;
                                        if (msg != null) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                                        }
                                      }
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Create'),
                            );
                          },
                        ),
                      ],
                  );
                },
              );
              titleController.clear();
              bodyController.clear();
            },
            icon: const Icon(Icons.forum),
            label: const Text('New Thread'),
          ),
          body: BlocBuilder<ThreadsBloc, ThreadsState>(
            builder: (context, state) {
              if (state is ThreadsLoading || state is ThreadsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is ThreadsError) {
                return ListView(children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading threads: ${state.message}'),
                  ),
                ]);
              }
              if (state is ThreadsLoaded) {
                final threads = state.threads;
                // After build, fetch missing usernames' roles using SearchService
                final names = threads.map((t) => t.createdByUsername).toSet();
                final missing = names
                    .where((n) => !(verifiedMap.value.containsKey(n) || fetching.value.contains(n)))
                    .toList();
                if (missing.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    final service = getIt<SearchService>();
                    fetching.value = {...fetching.value, ...missing};
                    final updated = Map<String, bool>.from(verifiedMap.value);
                    for (final name in missing) {
                      try {
                        final results = await service.searchMembers(name);
                        if (results.isNotEmpty) {
                          final u = results.firstWhere(
                            (e) => e.username.toLowerCase() == name.toLowerCase(),
                            orElse: () => results.first,
                          );
                          updated[name] = (u.role == Role.verifiedMember);
                        }
                      } catch (_) {
                        // ignore errors; leave as unknown
                      }
                    }
                    verifiedMap.value = updated;
                    final newFetching = {...fetching.value}..removeAll(missing);
                    fetching.value = newFetching;
                  });
                }
                if (threads.isEmpty) {
                  return ListView(children: const [
                    SizedBox(height: 120),
                    Center(child: Text('No threads yet. Be the first!')),
                  ]);
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<ThreadsBloc>().add(LoadThreads(contentId: content.id)),
                  child: BlocBuilder<UserProfileBloc, UserProfileState>(
                    builder: (context, upState) {
                      final canModerate = upState is UserProfileLoaded &&
                          (upState.user.role == Role.moderator || upState.user.role == Role.admin);
                      return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final t = threads[index];
                      return Card(
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: Row(
                            children: [
                              const Text('by ', style: TextStyle(color: Colors.grey)),
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        t.createdByUsername,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    if (verifiedMap.value[t.createdByUsername] == true) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.verified,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('• ${t.postCount} posts • ${timeAgo(t.updatedAt)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canModerate)
                                IconButton(
                                  tooltip: 'Delete thread',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete thread?'),
                                        content: const Text('This will remove the thread and all its posts.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      context.read<ThreadsBloc>().add(DeleteThread(contentId: content.id, threadId: t.id));
                                    }
                                  },
                                ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ThreadDetailPage(
                                  threadId: t.id,
                                  threadTitle: t.title,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
    );
  }
}
