import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/content/content_bloc.dart';
import '../../bloc/content/content_event.dart';
import '../../bloc/content/content_state.dart';
import '../../dto/request/content_request_dto.dart';
import '../../dto/response/content_response_dto.dart';
import '../../model/actor.dart';
import '../../model/director.dart';
import '../../styles/app_colors.dart';
import 'genres_section.dart';

class ContentFormWrapper extends HookWidget {
  const ContentFormWrapper({
    super.key,
    required this.title,
    required this.submitButtonText,
    required this.onSubmit,
    this.isLoading = false,
    this.initialContent,
  });

  final String title;
  final String submitButtonText;
  final Function(ContentRequestDto request) onSubmit;
  final bool isLoading;
  final ContentResponseDto? initialContent;

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    
    // Form controllers
    final titleCtrl = useTextEditingController();
    final descriptionCtrl = useTextEditingController();
    final trailerUrlCtrl = useTextEditingController();
    
    // State variables
    final contentType = useState<String?>(null);
    final selectedGenres = useState<List<String>>([]);
    final actors = useState<List<Actor>>([]);
    final directors = useState<List<Director>>([]);
    final base64Image = useState<String?>(null);
    final contentTypes = useState<List<String>>([]);
    final genres = useState<List<String>>([]);
    final customContentTypeCtrl = useTextEditingController();
    final showCustomInput = useState<bool>(false);
    
    // Form validation
    final isFormValid = useState(false);
    
    void validateForm() {
      final hasValidContentType = contentType.value != null || 
          (showCustomInput.value && customContentTypeCtrl.text.trim().isNotEmpty);
      
      isFormValid.value = titleCtrl.text.isNotEmpty &&
          descriptionCtrl.text.isNotEmpty &&
          hasValidContentType &&
          selectedGenres.value.isNotEmpty &&
          actors.value.isNotEmpty &&
          directors.value.isNotEmpty;
    }

    // Listen to text changes for validation
    useEffect(() {
      void listener() => validateForm();
      titleCtrl.addListener(listener);
      descriptionCtrl.addListener(listener);
      customContentTypeCtrl.addListener(listener);
      return () {
        titleCtrl.removeListener(listener);
        descriptionCtrl.removeListener(listener);
        customContentTypeCtrl.removeListener(listener);
      };
    }, [titleCtrl, descriptionCtrl, customContentTypeCtrl]);

    // Listen to other changes for validation
    useEffect(() {
      validateForm();
      return null;
    }, [contentType.value, selectedGenres.value, actors.value, directors.value, showCustomInput.value]);

    Future<void> pickImage() async {
      try {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 75,
        );
        if (image != null) {
          final bytes = await image.readAsBytes();
          base64Image.value = base64Encode(bytes);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    void addActor() {
      final newActors = List<Actor>.from(actors.value);
      newActors.add(Actor(firstName: '', lastName: ''));
      actors.value = newActors;
    }

    void removeActor(String id) {
      final newActors = List<Actor>.from(actors.value);
      newActors.removeWhere((actor) => actor.id == id);
      actors.value = newActors;
    }

    void updateActor(int index, String firstName, String lastName) {
      final newActors = List<Actor>.from(actors.value);
      newActors[index] = Actor(
        id: newActors[index].id,
        firstName: firstName, 
        lastName: lastName,
      );
      actors.value = newActors;
    }

    void addDirector() {
      final newDirectors = List<Director>.from(directors.value);
      newDirectors.add(Director(firstName: '', lastName: ''));
      directors.value = newDirectors;
    }

    void removeDirector(String id) {
      final newDirectors = List<Director>.from(directors.value);
      newDirectors.removeWhere((director) => director.id == id);
      directors.value = newDirectors;
    }

    void updateDirector(int index, String firstName, String lastName) {
      final newDirectors = List<Director>.from(directors.value);
      newDirectors[index] = Director(
        id: newDirectors[index].id,
        firstName: firstName, 
        lastName: lastName,
      );
      directors.value = newDirectors;
    }

    void handleSubmit() {
      if (!isFormValid.value) return;
      
      // Filter out empty actors and directors
      final validActors = actors.value.where((actor) =>
        actor.firstName.trim().isNotEmpty && actor.lastName.trim().isNotEmpty
      ).toList();
      
      final validDirectors = directors.value.where((director) =>
        director.firstName.trim().isNotEmpty && director.lastName.trim().isNotEmpty
      ).toList();
      
      final request = ContentRequestDto(
        title: titleCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        contentType: contentType.value!,
        genres: selectedGenres.value,
        actors: validActors,
        directors: validDirectors,
        base64Image: base64Image.value,
        trailerUrl: trailerUrlCtrl.text.trim().isEmpty ? null : trailerUrlCtrl.text.trim(),
      );
      
      onSubmit(request);
    }

    // Initialize form with initial content or empty values
    useEffect(() {
      if (initialContent != null) {
        // Pre-fill form with existing content data
        titleCtrl.text = initialContent!.title;
        descriptionCtrl.text = initialContent!.description;
        trailerUrlCtrl.text = initialContent!.trailerUrl ?? '';
        contentType.value = initialContent!.contentType;
        selectedGenres.value = initialContent!.genres;
        actors.value = initialContent!.actors.isNotEmpty 
            ? initialContent!.actors 
            : [Actor(firstName: '', lastName: '')];
        directors.value = initialContent!.directors.isNotEmpty 
            ? initialContent!.directors 
            : [Director(firstName: '', lastName: '')];
        base64Image.value = initialContent!.base64Image;
      } else {
        // Initialize with at least one actor and director for new content
        if (actors.value.isEmpty) {
          actors.value = [Actor(firstName: '', lastName: '')];
        }
        if (directors.value.isEmpty) {
          directors.value = [Director(firstName: '', lastName: '')];
        }
      }
      // Load content types and genres from ContentService
      context.read<ContentBloc>().add(const LoadContentTypesRequested());
      context.read<ContentBloc>().add(const LoadGenresRequested());
      return null;
    }, []);

    return BlocListener<ContentBloc, ContentState>(
      listener: (context, state) {
        if (state is ContentTypesLoaded) {
          contentTypes.value = state.contentTypes;
        } else if (state is ContentTypesError) {
          // Show error message and provide fallback content types
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load content types: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is GenresLoaded) {
          genres.value = state.genres;
        } else if (state is GenresError) {
          // Show error message for genres
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load genres: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Content Title Field
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Content Title *',
                    hintText: 'Enter the title of your content',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: descriptionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Enter a description of your content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Content Type Dropdown with Add New Option
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: showCustomInput.value ? null : (
                        contentTypes.value.contains(contentType.value) ? contentType.value : null
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Content Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        ...contentTypes.value.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }),
                        const DropdownMenuItem(
                          value: '__ADD_NEW__',
                          child: Text('+ Add New Type'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == '__ADD_NEW__') {
                          showCustomInput.value = true;
                          contentType.value = null;
                        } else {
                          showCustomInput.value = false;
                          contentType.value = value;
                        }
                      },
                    ),
                    if (showCustomInput.value) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: customContentTypeCtrl,
                        decoration: InputDecoration(
                          labelText: 'Enter New Content Type',
                          hintText: 'e.g., Web Series, Podcast, etc.',
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  final newType = customContentTypeCtrl.text.trim();
                                  if (newType.isNotEmpty && !contentTypes.value.contains(newType)) {
                                    final updatedTypes = List<String>.from(contentTypes.value);
                                    updatedTypes.add(newType);
                                    contentTypes.value = updatedTypes;
                                    contentType.value = newType;
                                    showCustomInput.value = false;
                                    customContentTypeCtrl.clear();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  showCustomInput.value = false;
                                  customContentTypeCtrl.clear();
                                },
                              ),
                            ],
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (value) {
                          final newType = value.trim();
                          if (newType.isNotEmpty && !contentTypes.value.contains(newType)) {
                            final updatedTypes = List<String>.from(contentTypes.value);
                            updatedTypes.add(newType);
                            contentTypes.value = updatedTypes;
                            contentType.value = newType;
                            showCustomInput.value = false;
                            customContentTypeCtrl.clear();
                          }
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // Genres Section
                GenresSection(
                  availableGenres: genres.value,
                  selectedGenres: selectedGenres.value,
                  onGenresChanged: (newGenres) {
                    selectedGenres.value = newGenres;
                  },
                ),
                const SizedBox(height: 24),

                // Actors Section
                _buildPersonSection(
                  context,
                  'Actors *',
                  actors.value,
                  addActor,
                  removeActor,
                  updateActor,
                ),
                const SizedBox(height: 24),

                // Directors Section
                _buildPersonSection(
                  context,
                  'Directors *',
                  directors.value,
                  addDirector,
                  removeDirector,
                  updateDirector,
                ),
                const SizedBox(height: 24),

                // Image Section
                _buildImageSection(context, base64Image.value, pickImage),
                const SizedBox(height: 16),

                // Trailer URL Field
                TextFormField(
                  controller: trailerUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Trailer URL (Optional)',
                    hintText: 'Enter the trailer URL',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading || !isFormValid.value ? null : handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            submitButtonText,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      )
    );
  }

  Widget _buildPersonSection(
    BuildContext context,
    String title,
    List<dynamic> people,
    VoidCallback onAdd,
    Function(String) onRemove,
    Function(int, String, String) onUpdate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...people.asMap().entries.map((entry) {
          final index = entry.key;
          final person = entry.value;
          final personId = person is Actor ? person.id : (person is Director ? person.id : '');
          return Padding(
            key: ValueKey(personId),
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: person.firstName,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      onUpdate(index, value, person.lastName);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: person.lastName,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      onUpdate(index, person.firstName, value);
                    },
                  ),
                ),
                if (people.length > 1)
                  IconButton(
                    onPressed: () => onRemove(personId),
                    icon: const Icon(Icons.remove_circle),
                    color: Colors.red,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    String? base64Image,
    VoidCallback onPickImage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Image (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (base64Image != null) ...[
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                base64Decode(base64Image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.image),
          label: Text(base64Image != null ? 'Change Image' : 'Select Image'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}