import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../screens/add_content_screen.dart';
import '../bloc/content/content_bloc.dart';
import '../bloc/content/content_event.dart';
import '../bloc/content/content_state.dart';
import '../dto/response/content_response_dto.dart';

class ManageContentsPage extends HookWidget {
  const ManageContentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contentBloc = context.read<ContentBloc>();

    useEffect(() {
      contentBloc.add(const LoadMyContentsRequested());
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Contents'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ContentBloc, ContentState>(
            builder: (context, state) {
              if (state is ContentLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ContentError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Error loading contents',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          contentBloc.add(const LoadMyContentsRequested());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (state is ContentLoaded) {
                if (state.contents.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_creation_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 24),
                        Text(
                          'No contents yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Start creating your first content by tapping the + button',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: state.contents.length,
                  itemBuilder: (context, index) {
                    final content = state.contents[index];
                    return _buildContentCard(context, content);
                  },
                );
              }
              
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_creation_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddContentScreen(),
            ),
          );

          contentBloc.add(const LoadMyContentsRequested());
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, ContentResponseDto content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Image on the left
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: content.base64Image != null && content.base64Image!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildSafeImage(content.base64Image!),
                    )
                  : const Icon(
                      Icons.movie,
                      size: 40,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(width: 16),
            // Content info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.contentType,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Action buttons
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    _handleEditContent(context, content);
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    _handleDeleteContent(context, content);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeImage(String base64Image) {
    try {
      final bytes = base64Decode(base64Image);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
      );
    } catch (e) {
      // Any parsing or decoding error - return fallback icon
      return const Icon(
        Icons.movie,
        size: 40,
        color: Colors.grey,
      );
    }
  }

  void _handleEditContent(BuildContext context, ContentResponseDto content) {
    // TODO: Navigate to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${content.title} - Feature coming soon')),
    );
  }

  void _handleDeleteContent(BuildContext context, ContentResponseDto content) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Content'),
          content: Text('Are you sure you want to delete "${content.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // TODO: Implement delete functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete ${content.title} - Feature coming soon')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}