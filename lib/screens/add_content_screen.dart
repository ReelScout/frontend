import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../bloc/content/content_bloc.dart';
import '../bloc/content/content_event.dart';
import '../bloc/content/content_state.dart';
import '../components/content/content_form_wrapper.dart';
import '../dto/request/content_request_dto.dart';
import '../styles/app_colors.dart';

class AddContentScreen extends HookWidget {
  const AddContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void handleSubmit(ContentRequestDto request) {
      context.read<ContentBloc>().add(AddContentRequested(contentRequest: request));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Content'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<ContentBloc, ContentState>(
        listener: (context, state) {
          if (state is ContentAddSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Content added successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else if (state is ContentAddError) {
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
            final isLoading = state is ContentAdding;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ContentFormWrapper(
                  title: 'Create New Content',
                  submitButtonText: 'Add Content',
                  onSubmit: handleSubmit,
                  isLoading: isLoading,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}