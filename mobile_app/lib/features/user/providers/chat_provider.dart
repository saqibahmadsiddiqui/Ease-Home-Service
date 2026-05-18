// GENERATED FILE - chat_provider.dart
// Riverpod 2.x provider for chat functionality using Firebase Realtime Database.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

// Message model representing a chat message.
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String? attachmentUrl;
  final DateTime timestamp;
  final bool isSystem;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.attachmentUrl,
    required this.timestamp,
    required this.isSystem,
  });

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map, String key) {
    return ChatMessage(
      id: key,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      attachmentUrl: map['attachmentUrl'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as num?)?.toInt() ?? 0),
      isSystem: map['isSystem'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isSystem': isSystem,
    };
  }
}

/// Service handling chat operations for a specific booking.
class ChatService {
  final Ref _ref;
  final String _bookingId;
  final DatabaseReference _chatRef;

  ChatService(this._ref, this._bookingId)
      : _chatRef = FirebaseDatabase.instance.ref('chat/$_bookingId/messages');

  /// Returns a stream of ordered messages for the booking.
  Stream<List<ChatMessage>> messagesStream() {
    return _chatRef.orderByChild('timestamp').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => ChatMessage.fromMap(e.value as Map<dynamic, dynamic>, e.key))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    });
  }

  /// Sends a new message to the chat.
  Future<void> sendMessage({
    required String text,
    String? attachmentUrl,
    bool isSystem = false,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final senderId = user?.uid ?? 'anonymous';
    final newMessageRef = _chatRef.push();
    final message = ChatMessage(
      id: newMessageRef.key ?? '',
      senderId: senderId,
      text: text,
      attachmentUrl: attachmentUrl,
      timestamp: DateTime.now(),
      isSystem: isSystem,
    );
    await newMessageRef.set(message.toMap());
  }

  /// Marks a message as read by setting a "readBy" field for the current user.
  Future<void> markRead(String messageId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final readRef = _chatRef.child(messageId).child('readBy');
    await readRef.update({user.uid: true});
  }
}

/// Riverpod provider family that creates a [ChatService] for a given booking ID.
final chatProvider = Provider.family<ChatService, String>((ref, bookingId) {
  return ChatService(ref, bookingId);
});
