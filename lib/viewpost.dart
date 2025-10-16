import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/privatechart.dart';
import 'package:grainapp/public%20chats.dart';

class ViewPost extends StatefulWidget {
  final String pid;
  final String userId_;
 final postuid;
  const ViewPost({super.key, required this.pid,required this.userId_,required this.postuid});

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
 Stream<DocumentSnapshot<Map<String, dynamic>>> getUsers() {
  return FirebaseFirestore.instance
      .collection('userpost')
      .doc(widget.pid)
      .snapshots();
}
  Stream<bool> isLikedByUser() {
    return FirebaseFirestore.instance
        .collection('post_likes')
        .doc('${widget.userId_}.${widget.pid}')
        .snapshots()
        .map((doc) => doc.exists);
  }
    Stream<int> getLikeCount() {
    return FirebaseFirestore.instance
        .collection('post_likes')
        .where('post_id', isEqualTo: widget.pid)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
    Future<void> toggleLike() async {
    final likeDoc = FirebaseFirestore.instance
        .collection('post_likes')
        .doc('${widget.userId_}${widget.pid}');

    final likeSnapshot = await likeDoc.get();

    if (likeSnapshot.exists) {
      // Unlike the post
      await likeDoc.delete();
    } else {
      // Like the post
      await likeDoc.set({
        'user_id': widget.userId_,
        'post_id': widget.pid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
         iconTheme: IconThemeData(color:Colors.white),
        backgroundColor: Colors.blueGrey.shade800.withOpacity(0.5),
        title: const Center(
          child: Text(
            'Product Image',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                margin: const EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey[800]!,
                        Colors.blueGrey[800]!,
                        Colors.black87,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  stream: getUsers(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || !snapshot.data!.exists) {
      return const Center(child: Text('No data available'));
    }

    var doc = snapshot.data!.data();
    if (doc == null) {
      return const Center(child: Text('Document is empty'));
    }

    Timestamp timestamp = doc['created_at'];
    DateTime dateTime = timestamp.toDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.blueGrey.shade900],
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              doc['pname'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Image Explanation
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey[600],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            doc['expl'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 10),

        // Details Section
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueGrey[500],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                icon: Icons.storage,
                label: "Quantity:",
                value: "${doc['quantyty']} kg",
              ),
              _buildDetailRow(
                icon: Icons.location_on,
                label: "Location:",
                value:
                    "${doc['region']}, ${doc['distrname']} - ${doc['mtaa']}",
              ),
              _buildDetailRow(
                icon: Icons.phone,
                label: "Phone:",
                value: doc['phone'],
              ),
              _buildDetailRow(
                icon: Icons.access_time,
                label: "Posted at:",
                value: dateTime.toString(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Product Image
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            'images/image3.jpeg',
            height: 180,
            width: MediaQuery.of(context).size.width * 0.9,
            fit: BoxFit.cover,
          ),
        ),


       StreamBuilder<int>(
                  stream: FirebaseFirestore.instance
                      .collection('comments')
                      .where('prid', isEqualTo: widget.pid)
                      .snapshots()
                      .map((snapshot) => snapshot.docs.length),
                  builder: (context, sdatalSnapshot) {
                  final commentl = sdatalSnapshot.data ?? 0;
               return    StreamBuilder<int>(
              stream: getLikeCount(),
              builder: (context, snapshot) {
                final likeCount = snapshot.data ?? 0;
               return StreamBuilder<bool>(
                  stream: isLikedByUser(),
                  builder: (context, likeSnapshot) {
                  final isLiked = likeSnapshot.data ?? false;
                  return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Like Button
                                  ElevatedButton.icon(
                          onPressed: toggleLike,
                          icon: Icon(
                            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            '$likeCount Likes',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                                  // Comment Button
                                  InteractiveButton(
                                    icon: Icons.comment,
                                    label: 'Comments',
                                    count: commentl, // Replace with actual comment count
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatScreen(pid:widget.pid,uid:widget.userId_),
                                        ),
                                      );
                                    },
                                  ),
                              
                                ],
                              ); 
                              
              });
                  });
                  }),
          
                      const SizedBox(height: 16),

                              // Delete Button
                              widget.userId_!=widget.postuid? Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if(widget.userId_!=widget.postuid){
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatListScreen(chatId:widget.pid,currentUserId:widget.userId_, postuid: widget.postuid,),//ChartScreen supposed!
                                        ),
                                      );
                                    }
                                   
                                  },

                                  icon: const Icon(Icons.chat_bubble_sharp,
                                      color: Colors.white),
                                  label: const Text('Private chats',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ):SizedBox(height: 1,width: 1,),
      ],
    );
  },
)

                ),
              ),
            ),

            // Bottom Container with Text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.blueGrey.shade900,
              ),
              height: MediaQuery.of(context).size.height * 0.25,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.2,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label $value",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InteractiveButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onPressed;

  const InteractiveButton({super.key, 
    required this.icon,
    required this.label,
    this.count,
    required this.onPressed,
  });
 @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade100,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blueGrey.shade900),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontSize: 16,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 10),
            Text(
              count.toString(),
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
