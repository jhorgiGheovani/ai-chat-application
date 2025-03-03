import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final int credits;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isOnboarded;
  final String? fcmToken;
  final String locale;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.credits = 0,
    required this.createdAt,
    required this.lastActive,
    this.isOnboarded = false,
    this.fcmToken,
    this.locale = 'en',
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      credits: data['credits'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive:
          (data['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOnboarded: data['isOnboarded'] ?? false,
      fcmToken: data['fcmToken'],
      locale: data['locale'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'credits': credits,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isOnboarded': isOnboarded,
      'fcmToken': fcmToken,
      'locale': locale,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    int? credits,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isOnboarded,
    String? fcmToken,
    String? locale,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      fcmToken: fcmToken ?? this.fcmToken,
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        photoUrl,
        credits,
        createdAt,
        lastActive,
        isOnboarded,
        fcmToken,
        locale,
      ];
}
