import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/credits_provider.dart';

class CreditPackageCard extends StatelessWidget {
  final PurchasePackage package;
  final VoidCallback onTap;

  const CreditPackageCard({
    Key? key,
    required this.package,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: package.isPopular || package.isBestValue
            ? Border.all(
                color:
                    package.isPopular ? AppColors.primary : AppColors.secondary,
                width: 2,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Popular/Best Value label
                if (package.isPopular || package.isBestValue)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: package.isPopular
                          ? AppColors.primary
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      package.isPopular ? 'MOST POPULAR' : 'BEST VALUE',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Package details
                Row(
                  children: [
                    // Credits icon and amount
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.credits.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.credits,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            package.creditsAmount.toString(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Package name and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: AppTextStyles.h4,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            package.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Discount price
                        if (package.discount > 0)
                          Text(
                            '${package.currency} ${(package.price * (1 + package.discount / 100)).toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                            ),
                          ),

                        // Current price
                        Text(
                          '${package.currency} ${package.price.toStringAsFixed(2)}',
                          style: AppTextStyles.h4.copyWith(
                            color: package.discount > 0
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),

                        // Discount badge
                        if (package.discount > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${package.discount.toStringAsFixed(0)}%',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
