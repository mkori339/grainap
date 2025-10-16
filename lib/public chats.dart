import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String pid;
  final String uid;
  const ChatScreen({super.key, required this.pid,required this.uid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade800.withOpacity(0.4),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey.shade900,
        title: Text(
          'PUBLIC COMMENTS',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('prid', isEqualTo: widget.pid)
                    //.orderBy('time', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No comments yet.'));
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                    return ChatBubble(
                        message: comment['message'],
                        isMe: comment['userId'].toString() ==widget.uid , // Replace 'own' with the current user's ID
                        time: comment['time'],
                        profilePicture: comment['profileImage'],
                        senderName: comment['userName'],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Add Comment Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blueGrey.shade900,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Add a comment...',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.comment, color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blueGrey.shade400),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _addComment(widget.pid);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Post",
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addComment(String pid) async {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;

    final commentData = {
      'prid':pid,
      'message': message,
      'userName': 'John Doe',
      'userId': widget.uid, // Replace 'own' with the actual user ID
      'profileImage': 'https://via.placeholder.com/150',
      'time': DateTime.now().toIso8601String(),
    };

    await FirebaseFirestore.instance.collection('comments').add(commentData);
    _commentController.clear();
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final String profilePicture;
  final String senderName;

  const ChatBubble({super.key, 
    required this.message,
    required this.isMe,
    required this.time,
    required this.profilePicture,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isMe ? Radius.circular(20) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profilePicture),
                  radius: 15,
                ),
                SizedBox(width: 8),
                Text(
                  senderName,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
