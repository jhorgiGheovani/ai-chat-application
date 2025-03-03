import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class PurchasePackage {
  final String id;
  final String name;
  final String description;
  final int creditsAmount;
  final double price;
  final String currency;
  final String revenueCatId;
  final bool isPopular;
  final bool isBestValue;
  final double discount;

  PurchasePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.creditsAmount,
    required this.price,
    required this.currency,
    required this.revenueCatId,
    this.isPopular = false,
    this.isBestValue = false,
    this.discount = 0.0,
  });

  factory PurchasePackage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PurchasePackage(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creditsAmount: data['creditsAmount'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      revenueCatId: data['revenueCatId'] ?? '',
      isPopular: data['isPopular'] ?? false,
      isBestValue: data['isBestValue'] ?? false,
      discount: (data['discount'] ?? 0.0).toDouble(),
    );
  }
}

class PurchaseHistory {
  final String id;
  final String userId;
  final String packageId;
  final String packageName;
  final int creditsAmount;
  final double price;
  final String currency;
  final String transactionId;
  final DateTime purchaseDate;

  PurchaseHistory({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.packageName,
    required this.creditsAmount,
    required this.price,
    required this.currency,
    required this.transactionId,
    required this.purchaseDate,
  });

  factory PurchaseHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PurchaseHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      packageId: data['packageId'] ?? '',
      packageName: data['packageName'] ?? '',
      creditsAmount: data['creditsAmount'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      transactionId: data['transactionId'] ?? '',
      purchaseDate:
          (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'packageId': packageId,
      'packageName': packageName,
      'creditsAmount': creditsAmount,
      'price': price,
      'currency': currency,
      'transactionId': transactionId,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
    };
  }
}

class CreditsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  List<PurchasePackage> _packages = [];
  List<PurchaseHistory> _purchaseHistory = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  User? get currentUser => _currentUser;
  int get userCredits => _currentUser?.credits ?? 0;
  List<PurchasePackage> get packages => _packages;
  List<PurchaseHistory> get purchaseHistory => _purchaseHistory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Set current user
  void setCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Load credit packages
  Future<void> loadCreditPackages() async {
    _setLoading(true);

    try {
      final packagesSnapshot =
          await _firestore.collection('credit_packages').orderBy('price').get();

      _packages = packagesSnapshot.docs
          .map((doc) => PurchasePackage.fromFirestore(doc))
          .toList();

      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load credit packages: ${e.toString()}');
    }
  }

  // Load purchase history
  Future<void> loadPurchaseHistory(String userId) async {
    if (userId.isEmpty) return;

    _setLoading(true);

    try {
      final historySnapshot = await _firestore
          .collection('purchase_history')
          .where('userId', isEqualTo: userId)
          .orderBy('purchaseDate', descending: true)
          .get();

      _purchaseHistory = historySnapshot.docs
          .map((doc) => PurchaseHistory.fromFirestore(doc))
          .toList();

      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load purchase history: ${e.toString()}');
    }
  }

  // Add credits to user
  Future<void> addCredits(String userId, int amount) async {
    if (userId.isEmpty) return;

    try {
      // Update Firestore
      await _firestore.collection('users').doc(userId).update({
        'credits': FieldValue.increment(amount),
      });

      // Update local state if currentUser is set
      if (_currentUser != null && _currentUser!.id == userId) {
        _currentUser = _currentUser!.copyWith(
          credits: _currentUser!.credits + amount,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to add credits: ${e.toString()}');
    }
  }

  // Record purchase
  Future<void> recordPurchase({
    required String userId,
    required String packageId,
    required String packageName,
    required int creditsAmount,
    required double price,
    required String currency,
    required String transactionId,
  }) async {
    if (userId.isEmpty) return;

    try {
      final purchase = PurchaseHistory(
        id: '',
        userId: userId,
        packageId: packageId,
        packageName: packageName,
        creditsAmount: creditsAmount,
        price: price,
        currency: currency,
        transactionId: transactionId,
        purchaseDate: DateTime.now(),
      );

      // Add to Firestore
      await _firestore.collection('purchase_history').add(purchase.toMap());

      // Add credits to user
      await addCredits(userId, creditsAmount);

      // Reload purchase history
      await loadPurchaseHistory(userId);
    } catch (e) {
      _setError('Failed to record purchase: ${e.toString()}');
    }
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
