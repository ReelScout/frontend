import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../dto/response/content_response_dto.dart';
import '../dto/response/user_response_dto.dart';
import '../services/search_service.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';

class SearchScreen extends HookWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    
    return BlocProvider(
      create: (context) => SearchBloc(
        searchService: GetIt.instance<SearchService>(),
      ),
      child: BlocListener<SearchBloc, SearchState>(
        listener: (context, state) {
          // Handle any side effects if needed
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search header
                Text(
                  'Search Contents & Users',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Search bar
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    final isLoading = state is SearchLoading;
                    
                    return Card(
                      elevation: 4,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: searchController,
                          onChanged: (query) {
                            context.read<SearchBloc>().add(
                              SearchQueryChanged(query: query),
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search for movies, shows, actors...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          searchController.clear();
                                          context.read<SearchBloc>().add(
                                            const SearchClearRequested(),
                                          );
                                        },
                                      )
                                    : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Search results
                Expanded(
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      return _buildSearchResults(context, state);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchState state) {
    if (state is SearchError) {
      return _buildErrorState(context, state.message);
    }

    if (state is SearchInitial) {
      return _buildEmptyState(context);
    }

    if (state is SearchLoading) {
      return _buildEmptyState(context); // Loading indicator is in the search bar
    }

    if (state is SearchEmpty) {
      return _buildNoResultsState(context, state.query);
    }

    if (state is SearchLoaded) {
      return _buildResultsList(context, state.results);
    }

    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Start typing to search',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find your favorite movies, TV shows, and actors',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, String query) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No results found for "$query"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, dynamic results) {
    final hasContents = results.contents.isNotEmpty;
    final hasUsers = results.users.isNotEmpty;

    return ListView(
      children: [
        if (hasContents) ...[
          _buildSectionHeader(context, 'Movies & Shows', results.contents.length),
          ...results.contents.map((content) => _buildContentCard(context, content)),
          if (hasUsers) const SizedBox(height: 16),
        ],
        if (hasUsers) ...[
          _buildSectionHeader(context, 'Users', results.users.length),
          ...results.users.map((user) => _buildUserCard(context, user)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, ContentResponseDto content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: _buildSafeAvatar(
                base64Image: content.base64Image,
                fallback: Icon(Icons.tv)
        ),
        title: Text(content.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.description),
            const SizedBox(height: 4),
            Text(
              '${content.contentType} • ${content.genres.join(", ")}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserResponseDto user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: _buildSafeAvatar(
                base64Image: user.base64Image,
                fallback: Text(
                  user.username.substring(0, 1).toUpperCase(),
                ),
              ),
        title: Text(user.username),
        subtitle: Text(user.role.toString().split('.').last.toUpperCase()),
        trailing: const Icon(Icons.person),
      ),
    );
  }

  Widget _buildSafeAvatar({
    required String? base64Image,
    required Widget fallback,
  }) {
    try {
      final decodedBytes = base64Decode(base64Image!);
      return CircleAvatar(
        backgroundImage: MemoryImage(decodedBytes),
      );
    } catch (e) {
      // If base64 decoding fails, use the fallback widget
      return CircleAvatar(child: fallback);
    }
  }
}