import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameArticleDetailScreen extends StatelessWidget {
  final DocumentSnapshot article;

  const GameArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[500],
      appBar: AppBar(
        title: Text(article['title']),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['imageUrl'] != null)
              Center(
                child: Image.network(
                  article['imageUrl'],
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              article['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tác giả: ${article['author']}",
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 10),
            Text(
              "Ngày xuất bản: ${DateTime.parse(article['publishedDate']).toLocal()}",
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            const Divider(height: 30, thickness: 1),
            Text(
              article['content'],
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
