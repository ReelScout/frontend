import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/bloc/forum/posts_bloc.dart';
import 'package:frontend/bloc/forum/posts_event.dart';
import 'package:frontend/bloc/forum/posts_state.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/dto/response/forum_post_response_dto.dart';
import 'package:frontend/services/forum_service.dart';

class ThreadDetailPage extends HookWidget {
  const ThreadDetailPage({super.key, required this.threadId, required this.threadTitle});
  final int threadId;
  final String threadTitle;

  @override
  Widget build(BuildContext context) {
    final composerController = useTextEditingController();
    final replyingTo = useState<int?>(null); // parentId for nested reply
    final openReplyEditors = useState<Set<int>>({});

    return BlocProvider(
      create: (_) => PostsBloc(forumService: getIt<ForumService>())..add(LoadPosts(threadId: threadId)),
      child: BlocListener<PostsBloc, PostsState>(
        listenWhen: (p, n) => n is PostsLoaded && n.currentOperation != null,
        listener: (context, state) {
          if (state is PostsLoaded && state.currentOperation != null) {
            final op = state.currentOperation!;
            if (!op.isLoading && op.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(op.message!)));
              composerController.clear();
              replyingTo.value = null;
              openReplyEditors.value = {};
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(threadTitle)),
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
                                    onReply: (postId) {
                                      openReplyEditors.value = {...openReplyEditors.value}..add(postId);
                                    },
                                    onCancelReply: (postId) {
                                      openReplyEditors.value = {...openReplyEditors.value}..remove(postId);
                                    },
                                    showEditorFor: openReplyEditors.value,
                                    onSubmitReply: (postId, text) {
                                      context.read<PostsBloc>().add(CreatePost(threadId: threadId, body: text, parentId: postId));
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
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: composerController,
                          decoration: InputDecoration(
                            hintText: replyingTo.value == null ? 'Write a reply...' : 'Replying to #${replyingTo.value}',
                          ),
                          minLines: 1,
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      BlocBuilder<PostsBloc, PostsState>(
                        builder: (context, state) {
                          final isLoading = state is PostsLoaded && state.currentOperation?.isLoading == true;
                          return Row(children: [
                            if (replyingTo.value != null)
                              IconButton(
                                tooltip: 'Cancel reply',
                                icon: const Icon(Icons.close),
                                onPressed: () => replyingTo.value = null,
                              ),
                            IconButton(
                              icon: isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.send),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      final text = composerController.text.trim();
                                      if (text.isEmpty) return;
                                      context
                                          .read<PostsBloc>()
                                          .add(CreatePost(threadId: threadId, body: text, parentId: replyingTo.value));
                                    },
                            ),
                          ]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    required this.onReply,
    required this.onCancelReply,
    required this.onSubmitReply,
    required this.showEditorFor,
  });

  final _PostNode node;
  final int depth;
  final void Function(int postId) onReply;
  final void Function(int postId) onCancelReply;
  final void Function(int postId, String text) onSubmitReply;
  final Set<int> showEditorFor;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(left: depth * 16.0);
    final showEditor = showEditorFor.contains(node.post.id);
    final controller = TextEditingController();
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: Text(node.post.authorUsername),
              subtitle: Text(node.post.body),
              trailing: TextButton.icon(
                onPressed: () => onReply(node.post.id),
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('Reply'),
              ),
            ),
          ),
          if (showEditor)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Write a reply...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Cancel',
                    icon: const Icon(Icons.close),
                    onPressed: () => onCancelReply(node.post.id),
                  ),
                  IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      onSubmitReply(node.post.id, text);
                    },
                  ),
                ],
              ),
            ),
          for (final child in node.children)
            _PostNodeWidget(
              node: child,
              depth: depth + 1,
              onReply: onReply,
              onCancelReply: onCancelReply,
              onSubmitReply: onSubmitReply,
              showEditorFor: showEditorFor,
            ),
        ],
      ),
    );
  }
}

