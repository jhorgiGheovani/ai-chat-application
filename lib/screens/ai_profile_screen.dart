import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/ai_characters_provider.dart';
import '../providers/credits_provider.dart';
import '../models/ai_character.dart';
import '../widgets/profile/ai_info_card.dart';
import '../widgets/profile/review_item.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/loading_indicator.dart';

class AIProfileScreen extends StatefulWidget {
  const AIProfileScreen({Key? key}) : super(key: key);

  @override
  State<AIProfileScreen> createState() => _AIProfileScreenState();
}

class _AIProfileScreenState extends State<AIProfileScreen> {
  AICharacter? _character;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    final characterId =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    if (characterId.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final character =
          await Provider.of<AICharactersProvider>(context, listen: false)
              .getCharacterById(characterId);

      setState(() {
        _character = character;
        _isLoading = false;
      });

      if (_character == null) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final creditsProvider = Provider.of<CreditsProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _character?.name ?? 'AI Profile',
        showBackButton: true,
      ),
      body: _isLoading || _character == null
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image and basic info
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        // Character image
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: _character!.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: LoadingIndicator(size: 40),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error, size: 40),
                            ),
                          ),
                        ),

                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Character basic info
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _character!.name,
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _character!.profession,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _character!.rating.toStringAsFixed(1),
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_character!.reviewCount} reviews',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Short description
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _character!.shortDescription,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),

                  // Categories
                  if (_character!.categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _character!.categories
                            .map((category) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    category,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),

                  // Pricing info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AIInfoCard(
                      title: 'Chat Pricing',
                      content:
                          'This AI character costs ${_character!.chatCostPerMinute} credits per minute of chat time.',
                      icon: Icons.payment,
                      backgroundColor: AppColors.credits.withOpacity(0.1),
                      iconColor: AppColors.credits,
                    ),
                  ),

                  // Full description
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About ${_character!.name}',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _character!.description,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Reviews
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Reviews',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        // Mock reviews - in real app, these would come from Firestore
                        for (int i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ReviewItem(
                              username: 'User ${i + 1}',
                              rating: (_character!.rating - (i * 0.3))
                                  .clamp(1.0, 5.0),
                              comment:
                                  'This is a sample review for ${_character!.name}. The AI provides very insightful conversations and is quite knowledgeable.',
                              date: DateTime.now()
                                  .subtract(Duration(days: i * 7 + 1)),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom padding
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomSheet: _character == null
          ? null
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Credit info
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your credits: ${creditsProvider.userCredits}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(_character!.chatCostPerMinute > 0 ? (creditsProvider.userCredits / _character!.chatCostPerMinute).floor() : 0)} minutes available',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Start chat button
                  CustomButton(
                    text: 'Start Chat',
                    onPressed: () {
                      if (creditsProvider.userCredits >=
                          _character!.chatCostPerMinute) {
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'characterId': _character!.id,
                            'costPerMinute': _character!.chatCostPerMinute,
                          },
                        );
                      } else {
                        _showNotEnoughCreditsDialog();
                      }
                    },
                    icon: Icons.chat_bubble_outline,
                  ),
                ],
              ),
            ),
    );
  }

  void _showNotEnoughCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Not Enough Credits'),
        content: const Text(
            'You don\'t have enough credits to start a chat with this AI character. Would you like to purchase more credits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/purchase');
            },
            child: const Text('Buy Credits'),
          ),
        ],
      ),
    );
  }
}
