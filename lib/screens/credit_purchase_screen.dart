import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../providers/credits_provider.dart';
import '../widgets/common/custom_app_bar.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/purchase/credit_package_card.dart';
import '../widgets/purchase/purchase_history_item.dart';
import '../widgets/purchase/balance_display.dart';

class CreditPurchaseScreen extends StatefulWidget {
  const CreditPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<CreditPurchaseScreen> createState() => _CreditPurchaseScreenState();
}

class _CreditPurchaseScreenState extends State<CreditPurchaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load purchase history if user is logged in
    final creditsProvider =
        Provider.of<CreditsProvider>(context, listen: false);
    if (creditsProvider.currentUser != null) {
      creditsProvider.loadPurchaseHistory(creditsProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creditsProvider = Provider.of<CreditsProvider>(context);
    // final mixpanel = Provider.of<Mixpanel>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Credits',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Current balance card
          Padding(
            padding: const EdgeInsets.all(16),
            child: BalanceDisplay(
              credits: creditsProvider.userCredits,
              onAddCredits: () {
                _tabController.animateTo(0);
              },
            ),
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Buy Credits'),
                Tab(text: 'Purchase History'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Buy Credits Tab
                creditsProvider.isLoading
                    ? const Center(child: LoadingIndicator())
                    : _buildBuyCreditsTab(creditsProvider),

                // _buildBuyCreditsTab(creditsProvider, mixpanel),

                // Purchase History Tab
                creditsProvider.isLoading
                    ? const Center(child: LoadingIndicator())
                    : _buildPurchaseHistoryTab(creditsProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyCreditsTab(CreditsProvider creditsProvider) {
    return Stack(
      children: [
        // Packages list
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: creditsProvider.packages.length,
          itemBuilder: (context, index) {
            final package = creditsProvider.packages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CreditPackageCard(
                package: package,
                onTap: () => _handlePurchase(creditsProvider, package),
                // _handlePurchase(creditsProvider, mixpanel, package)
              ),
            );
          },
        ),

        // Loading overlay
        if (_isPurchasing)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildPurchaseHistoryTab(CreditsProvider creditsProvider) {
    final history = creditsProvider.purchaseHistory;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No purchase history yet',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your purchase history will appear here',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final purchase = history[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PurchaseHistoryItem(purchase: purchase),
        );
      },
    );
  }

  Future<void> _handlePurchase(
    CreditsProvider creditsProvider,
    // Mixpanel mixpanel,
    PurchasePackage package,
  ) async {
    // Check if user is logged in
    if (creditsProvider.currentUser == null) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      _isPurchasing = true;
    });

    try {
      // Start RevenueCat purchase flow
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;

      if (offering == null) {
        throw Exception('No offerings available');
      }

      final product = offering.availablePackages.firstWhere(
        (p) => p.identifier == package.revenueCatId,
        orElse: () => throw Exception('Package not found'),
      );

      // Make the purchase
      final purchaseResult = await Purchases.purchasePackage(product);

      // Record transaction in Firestore
      // await creditsProvider.recordPurchase(
      //   userId: creditsProvider.currentUser!.id,
      //   packageId: package.id,
      //   packageName: package.name,
      //   creditsAmount: package.creditsAmount,
      //   price: package.price,
      //   currency: package.currency,
      //   transactionId: purchaseResult.customerInfo.originalAppUserId,
      // );

      // Track purchase event in Mixpanel
      // mixpanel.track('Purchase Completed', properties: {
      //   'packageId': package.id,
      //   'packageName': package.name,
      //   'creditsAmount': package.creditsAmount,
      //   'price': package.price,
      //   'currency': package.currency,
      // });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully purchased ${package.creditsAmount} credits!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Handle purchase error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }

      // Track purchase error in Mixpanel
      // mixpanel.track('Purchase Failed', properties: {
      //   'packageId': package.id,
      //   'error': e.toString(),
      // });
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
      }
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
            'You need to be logged in to purchase credits. Please log in and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen (not implemented in this demo)
              // Navigator.pushNamed(context, '/login');
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }
}
