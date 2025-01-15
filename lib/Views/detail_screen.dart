import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String imageUrl;

  const DetailScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
