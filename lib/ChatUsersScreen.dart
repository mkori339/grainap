import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/privatechart.dart';

class ChatUsersScreen extends StatelessWidget {
  final String currentUserId;

  const ChatUsersScreen({super.key, required this.currentUserId});

  Future<Map<String, dynamic>> getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.exists ? doc.data() ?? {} : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserId)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No conversations yet."));
          }

          final chats = chatSnapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = List<String>.from(chat['participants'] ?? []);
              final otherUserId = participants.firstWhere(
                (uid) => uid != currentUserId,
                orElse: () => '',
              );

              if (otherUserId.isEmpty) return const SizedBox();

              final chatId = chat.id;

              return FutureBuilder(
                future: getUserData(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox();
                  final userData = userSnapshot.data!;
                  final name = userData['name'] ?? 'Unknown';
                  final profileImage = userData['profileImage'] ?? 'images/image2.jpeg';

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .snapshots(),
                    builder: (context, chatDocSnapshot) {
                      final unreadCounts = chatDocSnapshot.data?['unreadCounts'] ?? {};
                      final currentUserUnread = (unreadCounts as Map)[currentUserId] ?? 0;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(profileImage),
                          radius: 25,
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(chat['lastMessage'] ?? ''),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (chat['timestamp'] as Timestamp?)?.toDate().toString().substring(0, 16) ?? '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (currentUserUnread > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Text(
                                  '$currentUserUnread',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          // Navigate immediately
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatListScreen(
                                chatId: chatId,
                                currentUserId: currentUserId,
                                postuid: otherUserId,
                              ),
                            ),
                          );

                          // Mark as read in background
                          _markAsRead(chatId, participants);
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _markAsRead(String chatId, List<String> participants) async {
    try {
      final recipient = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (recipient.isEmpty) return;

      // Update unread count for current user
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .update({
        'unreadCounts.$currentUserId': FieldValue.delete(),
      });

      // Mark messages as read
      final unreadMessages = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print("Error marking as read: $e");
    }
  }
}