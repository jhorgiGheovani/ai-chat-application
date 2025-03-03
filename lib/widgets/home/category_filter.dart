import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/category.dart';

class CategoryFilter extends StatelessWidget {
  final List<Category> categories;
  final String selectedCategoryId;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All category option
          _buildCategoryItem(
            context: context,
            category: Category(
              id: '',
              name: 'All',
              icon: 'assets/images/all_icon.svg',
              order: -1,
            ),
            isSelected: selectedCategoryId.isEmpty,
          ),

          // Dynamic categories
          ...categories.map((category) => _buildCategoryItem(
                context: context,
                category: category,
                isSelected: selectedCategoryId == category.id,
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required Category category,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onCategorySelected(category.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icon
                if (category.icon.isNotEmpty) ...[
                  if (category.icon.endsWith('.svg'))
                    SvgPicture.asset(
                      category.icon,
                      width: 18,
                      height: 18,
                      color: isSelected ? Colors.white : AppColors.primary,
                    )
                  else
                    Icon(
                      Icons.category,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  const SizedBox(width: 8),
                ],

                // Text
                Text(
                  category.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
