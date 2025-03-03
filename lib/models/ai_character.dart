import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AICharacter extends Equatable {
  final String id;
  final String name;
  final String profession;
  final String description;
  final String shortDescription;
  final String imageUrl;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final int chatCostPerMinute;
  final bool isFeatured;
  final bool isPopular;
  final bool isNew;
  final DateTime createdAt;

  const AICharacter({
    required this.id,
    required this.name,
    required this.profession,
    required this.description,
    required this.shortDescription,
    required this.imageUrl,
    required this.categories,
    required this.rating,
    required this.reviewCount,
    required this.chatCostPerMinute,
    this.isFeatured = false,
    this.isPopular = false,
    this.isNew = false,
    required this.createdAt,
  });

  factory AICharacter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AICharacter(
      id: doc.id,
      name: data['name'] ?? '',
      profession: data['profession'] ?? '',
      description: data['description'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      categories: List<String>.from(data['categories'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      chatCostPerMinute: data['chatCostPerMinute'] ?? 1,
      isFeatured: data['isFeatured'] ?? false,
      isPopular: data['isPopular'] ?? false,
      isNew: data['isNew'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profession': profession,
      'description': description,
      'shortDescription': shortDescription,
      'imageUrl': imageUrl,
      'categories': categories,
      'rating': rating,
      'reviewCount': reviewCount,
      'chatCostPerMinute': chatCostPerMinute,
      'isFeatured': isFeatured,
      'isPopular': isPopular,
      'isNew': isNew,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        profession,
        description,
        shortDescription,
        imageUrl,
        categories,
        rating,
        reviewCount,
        chatCostPerMinute,
        isFeatured,
        isPopular,
        isNew,
        createdAt,
      ];
}
