import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/bloc/forum/posts_bloc.dart';
import 'package:frontend/bloc/forum/posts_event.dart';
import 'package:frontend/bloc/forum/posts_state.dart';
import 'package:frontend/dto/response/forum_post_response_dto.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/bloc/auth/auth_state.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/utils/time_ago.dart';

class ThreadDetailPage extends HookWidget {
  const ThreadDetailPage({super.key, required this.threadId, required this.threadTitle, this.focusPostId});
  final int threadId;
  final String threadTitle;
  final int? focusPostId;

  @override
  Widget build(BuildContext context) {
    final collapsed = useState<Set<int>>({});
    final scrolled = useState<bool>(false);

    // Ensure posts are loaded for this thread when entering the page
    useEffect(() {
      context.read<PostsBloc>().add(LoadPosts(threadId: threadId));
      return null;
    }, [threadId]);

    return BlocListener<PostsBloc, PostsState>(
        listenWhen: (p, n) => n is PostsLoaded && n.currentOperation != null,
        listener: (context, state) {
          if (state is PostsLoaded && state.currentOperation != null) {
            final op = state.currentOperation!;
            if (!op.isLoading && op.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(op.message!)));
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(threadTitle)),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.reply),
            label: const Text('Reply'),
            onPressed: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthSuccess) {
                final go = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Login required'),
                    content: const Text('You need to login to reply.'),
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
                if (context.read<AuthBloc>().state is! AuthSuccess) return;
              }
              await _openComposerBottomSheet(context, threadId: threadId);
            },
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, state) {
                    if (state is PostsLoading || state is PostsInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is PostsError) {
                      return ListView(children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error loading posts: ${state.message}'),
                        ),
                      ]);
                    }
                    if (state is PostsLoaded) {
                      final roots = _buildPostTree(state.posts);
                      // Build a stable key map for this frame
                      final postKeys = {
                        for (final p in state.posts) p.id: GlobalKey()
                      };
                      // Scroll to focus post if provided
                      if (!scrolled.value && focusPostId != null && postKeys[focusPostId] != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final ctx = postKeys[focusPostId!]!.currentContext;
                          if (ctx != null) {
                            Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300));
                            scrolled.value = true;
                          }
                        });
                      }
                      if (roots.isEmpty) {
                        return ListView(children: const [
                          SizedBox(height: 120),
                          Center(child: Text('No posts yet. Start the discussion!')),
                        ]);
                      }
                      return RefreshIndicator(
                        onRefresh: () async => context.read<PostsBloc>().add(LoadPosts(threadId: threadId)),
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: roots
                              .map((n) => _PostNodeWidget(
                                    node: n,
                                    depth: 0,
                                    keyFor: postKeys[n.post.id]!,
                                    postKeys: postKeys,
                                    collapsed: collapsed.value,
                                    onToggleCollapse: (postId) {
                                      final set = {...collapsed.value};
                                      if (set.contains(postId)) {
                                        set.remove(postId);
                                      } else {
                                        set.add(postId);
                                      }
                                      collapsed.value = set;
                                    },
                                    onReplyRequested: (postId, author) async {
                                      final authSt = context.read<AuthBloc>().state;
                                      if (authSt is! AuthSuccess) {
                                        final go = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Login required'),
                                            content: const Text('You need to login to reply.'),
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
                                        if (context.read<AuthBloc>().state is! AuthSuccess) return;
                                      }
                                      await _openComposerBottomSheet(context, threadId: threadId, parentId: postId, hint: 'Replying to @$author');
                                    },
                                  ))
                              .toList(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _PostNode {
  _PostNode(this.post);
  final ForumPostResponseDto post;
  final List<_PostNode> children = [];
}

List<_PostNode> _buildPostTree(List<ForumPostResponseDto> posts) {
  final Map<int, _PostNode> byId = {};
  final List<_PostNode> roots = [];
  for (final p in posts) {
    byId[p.id] = _PostNode(p);
  }
  for (final p in posts) {
    final node = byId[p.id]!;
    final parentId = p.parentId;
    if (parentId == null) {
      roots.add(node);
    } else {
      final parent = byId[parentId];
      if (parent != null) {
        parent.children.add(node);
      } else {
        roots.add(node); // broken parent fallback
      }
    }
  }
  return roots;
}

class _PostNodeWidget extends StatelessWidget {
  const _PostNodeWidget({
    required this.node,
    required this.depth,
    required this.keyFor,
    required this.postKeys,
    required this.collapsed,
    required this.onToggleCollapse,
    required this.onReplyRequested,
  });

  final _PostNode node;
  final int depth;
  final GlobalKey keyFor;
  final Map<int, GlobalKey> postKeys;
  final Set<int> collapsed;
  final void Function(int postId) onToggleCollapse;
  final void Function(int postId, String authorUsername) onReplyRequested;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(left: depth * 16.0);
    return Padding(
      key: keyFor,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: Row(
                children: [
                  Expanded(child: Text(node.post.authorUsername, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Text(timeAgo(node.post.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(node.post.body),
              ),
              trailing: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (node.children.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => onToggleCollapse(node.post.id),
                      icon: Icon(collapsed.contains(node.post.id) ? Icons.unfold_more : Icons.unfold_less, size: 18),
                      label: Text(
                        collapsed.contains(node.post.id)
                            ? 'Show ${node.children.length}'
                            : 'Hide ${node.children.length}',
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => onReplyRequested(node.post.id, node.post.authorUsername),
                    icon: const Icon(Icons.reply, size: 18),
                    label: const Text('Reply'),
                  ),
                ],
              ),
            ),
          ),
          if (!collapsed.contains(node.post.id))
            for (final child in node.children)
              _PostNodeWidget(
                node: child,
                depth: depth + 1,
                keyFor: postKeys[child.post.id]!,
                postKeys: postKeys,
                collapsed: collapsed,
                onToggleCollapse: onToggleCollapse,
                onReplyRequested: onReplyRequested,
              ),
        ],
      ),
    );
  }
}

Future<void> _openComposerBottomSheet(
  BuildContext context, {
  required int threadId,
  int? parentId,
  String? hint,
}) async {
  final controller = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hint ?? 'Write a reply', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: BlocBuilder<PostsBloc, PostsState>(
                builder: (context, state) {
                  final isLoading = state is PostsLoaded && state.currentOperation?.isLoading == true;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: isLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send),
                        label: const Text('Send'),
                        onPressed: isLoading
                            ? null
                            : () async {
                                final text = controller.text.trim();
                                if (text.isEmpty) return;
                                context.read<PostsBloc>().add(CreatePost(threadId: threadId, body: text, parentId: parentId));
                                // Close after send; listener will show snackbar
                                Navigator.of(ctx).pop();
                              },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
