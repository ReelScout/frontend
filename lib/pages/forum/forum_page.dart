import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/bloc/forum/threads_bloc.dart';
import 'package:frontend/bloc/forum/threads_event.dart';
import 'package:frontend/bloc/forum/threads_state.dart';
import 'package:frontend/config/injection_container.dart';
import 'package:frontend/dto/request/create_thread_request_dto.dart';
import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/pages/forum/thread_detail_page.dart';
import 'package:frontend/services/forum_service.dart';

class ForumPage extends HookWidget {
  const ForumPage({super.key, required this.content});
  final ContentResponseDto content;

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final bodyController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    return BlocProvider(
      create: (_) => ThreadsBloc(forumService: getIt<ForumService>())
        ..add(LoadThreads(contentId: content.id)),
      child: BlocListener<ThreadsBloc, ThreadsState>(
        listenWhen: (prev, next) => next is ThreadsLoaded && next.currentOperation != null,
        listener: (context, state) {
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
              await showDialog<void>(
                context: context,
                builder: (context) {
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
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      BlocBuilder<ThreadsBloc, ThreadsState>(
                        builder: (context, state) {
                          final isLoading = state is ThreadsLoaded && state.currentOperation?.isLoading == true;
                          return FilledButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (!formKey.currentState!.validate()) return;
                                    context.read<ThreadsBloc>().add(
                                          CreateThread(
                                            contentId: content.id,
                                            request: CreateThreadRequestDto(
                                              title: titleController.text.trim(),
                                              body: bodyController.text.trim(),
                                            ),
                                          ),
                                        );
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
                if (threads.isEmpty) {
                  return ListView(children: const [
                    SizedBox(height: 120),
                    Center(child: Text('No threads yet. Be the first!')),
                  ]);
                }
                return RefreshIndicator(
                  onRefresh: () async => context.read<ThreadsBloc>().add(LoadThreads(contentId: content.id)),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final t = threads[index];
                      return Card(
                        child: ListTile(
                          title: Text(t.title),
                          subtitle: Text('by ${t.createdByUsername} • ${t.postCount} posts'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
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
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
