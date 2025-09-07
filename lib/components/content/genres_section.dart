import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class GenresSection extends HookWidget {
  const GenresSection({
    super.key,
    required this.availableGenres,
    required this.selectedGenres,
    required this.onGenresChanged,
    this.isRequired = true,
    this.readOnly = false,
  });

  final List<String> availableGenres;
  final List<String> selectedGenres;
  final void Function(List<String>) onGenresChanged;
  final bool isRequired;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    // Local controllers and state
    final genreSearchCtrl = useTextEditingController();
    final genreSearchText = useState<String>('');
    final localGenres = useState<List<String>>(availableGenres);
    final localSelectedGenres = useState<List<String>>(selectedGenres);

    // Sync with parent when selectedGenres changes
    useEffect(() {
      localSelectedGenres.value = selectedGenres;
      return null;
    }, [selectedGenres]);

    // Sync with parent when availableGenres changes
    useEffect(() {
      localGenres.value = availableGenres;
      return null;
    }, [availableGenres]);

    void updateSelectedGenres(List<String> newGenres) {
      localSelectedGenres.value = newGenres;
      onGenresChanged(newGenres);
    }

    void addGenre(String genre) {
      if (genre.trim().isNotEmpty && !localSelectedGenres.value.contains(genre)) {
        final updatedSelectedGenres = List<String>.from(localSelectedGenres.value);
        updatedSelectedGenres.add(genre);
        updateSelectedGenres(updatedSelectedGenres);
        
        // Add to available genres list if it's new
        if (!localGenres.value.contains(genre)) {
          final updatedGenres = List<String>.from(localGenres.value);
          updatedGenres.add(genre);
          localGenres.value = updatedGenres;
        }
      }
    }

    void removeGenre(String genre) {
      final updatedSelectedGenres = List<String>.from(localSelectedGenres.value);
      updatedSelectedGenres.remove(genre);
      updateSelectedGenres(updatedSelectedGenres);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          isRequired ? 'Genres *' : 'Genres',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Genres container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar inside the genres box
              TextField(
                controller: genreSearchCtrl,
                decoration: InputDecoration(
                  hintText: readOnly ? 'Search for genres...' : 'Search for genres or add new ones...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                onSubmitted: readOnly ? null : (value) {
                  final trimmedValue = value.trim();
                  addGenre(trimmedValue);
                  genreSearchCtrl.clear();
                  genreSearchText.value = '';
                },
                onChanged: (value) {
                  genreSearchText.value = value;
                },
              ),
              
              const SizedBox(height: 12),
              
              // Search suggestions (when typing)
              if (genreSearchText.value.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Show filtered existing genres
                      ...localGenres.value.where((genre) {
                        final searchText = genreSearchText.value.toLowerCase();
                        return genre.toLowerCase().contains(searchText) && 
                               !localSelectedGenres.value.contains(genre);
                      }).map((genre) {
                        return ListTile(
                          dense: true,
                          title: Text(genre),
                          leading: const Icon(Icons.category, size: 16),
                          onTap: () {
                            addGenre(genre);
                            genreSearchCtrl.clear();
                            genreSearchText.value = '';
                          },
                        );
                      }),
                      
                      // Show "Add new genre" option if no exact match found (only when not read-only)
                      if (!readOnly &&
                          genreSearchText.value.trim().isNotEmpty &&
                          !localGenres.value.any((genre) => genre.toLowerCase() == genreSearchText.value.toLowerCase()) &&
                          !localSelectedGenres.value.contains(genreSearchText.value.trim()))
                        ListTile(
                          dense: true,
                          title: Text('Add "${genreSearchText.value.trim()}"'),
                          leading: const Icon(Icons.add, size: 16, color: Colors.green),
                          onTap: () {
                            final newGenre = genreSearchText.value.trim();
                            addGenre(newGenre);
                            genreSearchCtrl.clear();
                            genreSearchText.value = '';
                          },
                        ),
                    ],
                  ),
                ),
              
              // Selected genres display
              if (localSelectedGenres.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Selected Genres:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: localSelectedGenres.value.map((genre) {
                    return Chip(
                      label: Text(genre),
                      onDeleted: () => removeGenre(genre),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    );
                  }).toList(),
                ),
              ],
              
              // Loading state
              if (localGenres.value.isEmpty && localSelectedGenres.value.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Loading genres...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Validation error message
        if (isRequired && localSelectedGenres.value.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please add at least one genre',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
