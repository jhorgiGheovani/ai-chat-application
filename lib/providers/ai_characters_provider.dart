import 'package:flutter/foundation.dart' hide Category;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ai_character.dart';
import '../models/category.dart';

class AICharactersProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AICharacter> _characters = [];
  List<Category> _categories = [];
  String _selectedCategoryId = '';
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<AICharacter> get characters => _characters;
  List<Category> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  List<AICharacter> get filteredCharacters {
    if (_selectedCategoryId.isEmpty) {
      return _characters;
    }

    return _characters
        .where(
            (character) => character.categories.contains(_selectedCategoryId))
        .toList();
  }

  List<AICharacter> get featuredCharacters {
    return _characters.where((character) => character.isFeatured).toList();
  }

  List<AICharacter> get popularCharacters {
    return _characters.where((character) => character.isPopular).toList();
  }

  List<AICharacter> get newCharacters {
    return _characters.where((character) => character.isNew).toList();
  }

  // Methods
  Future<void> loadCharacters() async {
    _setLoading(true);

    try {
      final charactersSnapshot =
          await _firestore.collection('ai_characters').get();

      _characters = charactersSnapshot.docs
          .map((doc) => AICharacter.fromFirestore(doc))
          .toList();

      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load AI characters: ${e.toString()}');
    }
  }

  Future<void> loadCategories() async {
    _setLoading(true);

    try {
      final categoriesSnapshot =
          await _firestore.collection('categories').orderBy('order').get();

      _categories = categoriesSnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .where((category) => category.isActive)
          .toList();

      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    }
  }

  void selectCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = '';
    } else {
      _selectedCategoryId = categoryId;
    }
    notifyListeners();
  }

  Future<AICharacter?> getCharacterById(String id) async {
    // First check if it's already loaded
    final character = _characters.firstWhere(
      (character) => character.id == id,
      orElse: () => AICharacter(
        id: '',
        name: '',
        profession: '',
        description: '',
        shortDescription: '',
        imageUrl: '',
        categories: [],
        rating: 0,
        reviewCount: 0,
        chatCostPerMinute: 0,
        createdAt: DateTime.now(),
      ),
    );

    if (character.id.isNotEmpty) {
      return character;
    }

    // If not found, try to fetch from Firestore
    try {
      final doc = await _firestore.collection('ai_characters').doc(id).get();

      if (doc.exists) {
        return AICharacter.fromFirestore(doc);
      }
    } catch (e) {
      _setError('Failed to get character: ${e.toString()}');
    }

    return null;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _errorMessage = '';
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
