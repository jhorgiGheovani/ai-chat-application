import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int order;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
    this.isActive = true,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'order': order,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [id, name, icon, order, isActive];
}
