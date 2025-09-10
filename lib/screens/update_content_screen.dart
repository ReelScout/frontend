import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:frontend/bloc/content/content_bloc.dart';
import 'package:frontend/bloc/content/content_event.dart';
import 'package:frontend/bloc/content/content_state.dart';
import 'package:frontend/components/content/content_form_wrapper.dart';
import 'package:frontend/dto/request/content_request_dto.dart';
import 'package:frontend/dto/response/content_response_dto.dart';
import 'package:frontend/styles/app_colors.dart';

class UpdateContentScreen extends HookWidget {
  const UpdateContentScreen({
    super.key,
    required this.content,
  });

  final ContentResponseDto content;

  @override
  Widget build(BuildContext context) {
    void handleSubmit(ContentRequestDto request) {
      context.read<ContentBloc>().add(UpdateContentRequested(
        contentId: content.id,
        contentRequest: request,
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Content'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<ContentBloc, ContentState>(
        listener: (context, state) {
          if (!context.mounted) return;
          if (state is ContentUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Content updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is ContentUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<ContentBloc, ContentState>(
          builder: (context, state) {
            final isLoading = state is ContentUpdating;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ContentFormWrapper(
                  title: 'Edit Content',
                  submitButtonText: 'Update Content',
                  onSubmit: handleSubmit,
                  isLoading: isLoading,
                  initialContent: content,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
