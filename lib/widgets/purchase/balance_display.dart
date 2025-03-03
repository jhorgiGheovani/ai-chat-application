import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class BalanceDisplay extends StatelessWidget {
  final int credits;
  final VoidCallback onAddCredits;

  const BalanceDisplay({
    Key? key,
    required this.credits,
    required this.onAddCredits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Your Balance',
            style: AppTextStyles.h4.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),

          // Credits amount
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                color: AppColors.credits,
                size: 36,
              ),
              const SizedBox(width: 12),
              Text(
                '$credits',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add credits button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddCredits,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Add Credits',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
