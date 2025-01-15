import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Provider/favorite_provider.dart';
import '../Provider/quantity.dart';
import '../Utils/constain.dart';
import '../widget/my_icon_button.dart';

class RecipeDetailScreen extends StatefulWidget {
  final DocumentSnapshot<Object?> documentSnapshot;
  const RecipeDetailScreen({super.key, required this.documentSnapshot});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    List<double> baseAmounts = widget.documentSnapshot['ingredientsAmount']
        .map<double>((amount) => double.parse(amount.toString()))
        .toList();
    Provider.of<QuantityProvider>(context, listen: false)
        .setBaseIngredientAmounts(baseAmounts);
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> addToCart(DocumentSnapshot documentSnapshot) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final data = documentSnapshot.data() as Map<String, dynamic>;

      if (data.containsKey('value')) {
        // Kiểm tra nếu game đã có trong thư viện
        final libraryItem = await FirebaseFirestore.instance
            .collection("library")
            .doc(currentUser.email)
            .collection('games')
            .where('name', isEqualTo: data['name'])
            .get();

        if (libraryItem.docs.isNotEmpty) {
          // Nếu game đã có trong thư viện, không cho thêm vào giỏ hàng
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This game is already in your library!')),
          );
          return; // Dừng hàm nếu game đã có trong thư viện
        }

        // Kiểm tra nếu game đã có trong giỏ hàng
        final cartItem = await FirebaseFirestore.instance
            .collection("shopping-cart")
            .doc(currentUser.email)
            .collection('items')
            .where('name', isEqualTo: data['name'])
            .get();

        if (cartItem.docs.isEmpty) {
          await FirebaseFirestore.instance
              .collection("shopping-cart")
              .doc(currentUser.email)
              .collection('items')
              .add({
            'name': data['name'],
            'value': data['value'],
            'image': data['image'],
            'quantity': 1,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game đã thêm vào giỏ thành công')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game đã có trong giỏ hàng của bạn!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Value field is missing')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = FavoriteProvider.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: startCookingAndFavoriteButton(provider),
      backgroundColor: Colors.blueGrey[500],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2.1,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.documentSnapshot['image']),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      MyIconButton(
                        icon: Icons.arrow_back_ios_new,
                        pressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.documentSnapshot['name'],
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Iconsax.flash_1, color: Colors.grey[400]),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['data']} GB",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Iconsax.clock, color: Colors.grey[400]),
                      const SizedBox(width: 5),
                      Text(
                        "${widget.documentSnapshot['time']} Min",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Giới thiệu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Game cực hay.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Images",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: widget.documentSnapshot['ingredientsImage']
                          .map<Widget>((imageUrl) => Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(imageUrl),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Bình luận",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('userCm')
                        .where('recipeId',
                        isEqualTo: widget.documentSnapshot.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final comments = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey[400],
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['user'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          comment['comment'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          comment['timestamp'] != null
                                              ? (comment['timestamp'] as
                                          Timestamp)
                                              .toDate()
                                              .toLocal()
                                              .toString()
                                              .substring(0, 16)
                                              : 'N/A',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Thêm bình luận...",
                            filled: true,
                            fillColor: Colors.grey.shade400,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          if (_commentController.text.trim().isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('userCm')
                                .add({
                              'recipeId': widget.documentSnapshot.id,
                              'user': FirebaseAuth.instance
                                  .currentUser!.email,
                              'comment': _commentController.text.trim(),
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                            _commentController.clear();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kprimaryColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget startCookingAndFavoriteButton(FavoriteProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.1,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              addToCart(widget.documentSnapshot);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ), backgroundColor: kprimaryColor,
            ),
            child: Text(
              "Thêm vào giỏ hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[300]),

            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.1,
          child: IconButton(
            iconSize: 40,
            icon: Icon(
              provider.isExist(widget.documentSnapshot)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: provider.isExist(widget.documentSnapshot)
                  ? Colors.red
                  : Colors.grey[300],
            ),
            onPressed: () {
              provider.toggleFavorite(widget.documentSnapshot);
            },
          ),
        ),
      ],
    );
  }
}
