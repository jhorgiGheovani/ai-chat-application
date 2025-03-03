import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

enum MessageType {
  text,
  image,
  systemNotification,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final String senderId;
  final String receiverId;
  final String conversationId;
  final bool isUserMessage;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isDeleted;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.conversationId,
    required this.isUserMessage,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.isDeleted = false,
  });

  factory ChatMessage.create({
    required String content,
    required String senderId,
    required String receiverId,
    required String conversationId,
    required bool isUserMessage,
    MessageType type = MessageType.text,
  }) {
    return ChatMessage(
      id: const Uuid().v4(),
      content: content,
      senderId: senderId,
      receiverId: receiverId,
      conversationId: conversationId,
      isUserMessage: isUserMessage,
      type: type,
      status: MessageStatus.sending,
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      content: data['content'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      conversationId: data['conversationId'] ?? '',
      isUserMessage: data['isUserMessage'] ?? true,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${data['status'] ?? 'sent'}',
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'conversationId': conversationId,
      'isUserMessage': isUserMessage,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isDeleted': isDeleted,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    String? senderId,
    String? receiverId,
    String? conversationId,
    bool? isUserMessage,
    MessageType? type,
    MessageStatus? status,
    DateTime? timestamp,
    bool? isDeleted,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      conversationId: conversationId ?? this.conversationId,
      isUserMessage: isUserMessage ?? this.isUserMessage,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        senderId,
        receiverId,
        conversationId,
        isUserMessage,
        type,
        status,
        timestamp,
        isDeleted,
      ];
}
