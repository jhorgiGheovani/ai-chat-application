import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/ai_characters_provider.dart';
import '../providers/credits_provider.dart';
import '../models/ai_character.dart';
import '../widgets/home/ai_character_card.dart';
import '../widgets/home/category_filter.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final aiCharactersProvider = Provider.of<AICharactersProvider>(context);
    final creditsProvider = Provider.of<CreditsProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI Chat',
        showBackButton: false,
        actions: [
          // Credits display
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.credits.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.credits,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${creditsProvider.userCredits}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: aiCharactersProvider.isLoading
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await aiCharactersProvider.loadCharacters();
                await aiCharactersProvider.loadCategories();
              },
              child: CustomScrollView(
                slivers: [
                  // Category filters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: CategoryFilter(
                        categories: aiCharactersProvider.categories,
                        selectedCategoryId:
                            aiCharactersProvider.selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          aiCharactersProvider.selectCategory(categoryId);
                        },
                      ),
                    ),
                  ),

                  // Featured AI Characters
                  if (aiCharactersProvider.featuredCharacters.isNotEmpty) ...[
                    _buildSectionHeader('Featured'),
                    _buildHorizontalCharacterList(
                      aiCharactersProvider.featuredCharacters,
                    ),
                  ],

                  // Popular AI Characters
                  if (aiCharactersProvider.popularCharacters.isNotEmpty) ...[
                    _buildSectionHeader('Popular'),
                    _buildHorizontalCharacterList(
                      aiCharactersProvider.popularCharacters,
                    ),
                  ],

                  // New AI Characters
                  if (aiCharactersProvider.newCharacters.isNotEmpty) ...[
                    _buildSectionHeader('New'),
                    _buildHorizontalCharacterList(
                      aiCharactersProvider.newCharacters,
                    ),
                  ],

                  // All AI Characters (or filtered)
                  _buildSectionHeader(
                    aiCharactersProvider.selectedCategoryId.isEmpty
                        ? 'All Characters'
                        : 'Filtered Characters',
                  ),
                  _buildGridCharacterList(
                    aiCharactersProvider.filteredCharacters,
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/purchase');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: AppTextStyles.h3,
        ),
      ),
    );
  }

  Widget _buildHorizontalCharacterList(List<AICharacter> characters) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            return AICharacterCard(
              character: character,
              isHorizontal: true,
              onTap: () => _navigateToProfile(character),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGridCharacterList(List<AICharacter> characters) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final character = characters[index];
            return AICharacterCard(
              character: character,
              isHorizontal: false,
              onTap: () => _navigateToProfile(character),
            );
          },
          childCount: characters.length,
        ),
      ),
    );
  }

  void _navigateToProfile(AICharacter character) {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: character.id,
    );
  }
}
