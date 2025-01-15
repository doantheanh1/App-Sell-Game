import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameDetailScreen extends StatefulWidget {
  final DocumentSnapshot game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CollectionReference userComments =
      FirebaseFirestore.instance.collection('userCm');
  final currentUser = FirebaseAuth.instance.currentUser!;

  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      userComments.add({
        'gameId': widget.game.id,
        'userId': currentUser.uid,
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((_) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.game.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ...existing code...
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ...existing code...
                  const SizedBox(height: 20),
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _submitComment,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: userComments
                        .where('gameId', isEqualTo: widget.game.id)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            title: Text(comment['comment']),
                            subtitle: Text(comment['userId']),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
