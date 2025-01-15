import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import '../widget/my_icon_button.dart';
import '../Provider/favorite_provider.dart';
import 'cart_screen.dart'; // Import the cart screen

class ViewAllItems extends StatefulWidget {
  const ViewAllItems({super.key});

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  final CollectionReference completeApp =
      FirebaseFirestore.instance.collection("Complete-Flutter-App");
  final CollectionReference shoppingCart =
      FirebaseFirestore.instance.collection("shopping-cart");

  String searchQuery = ""; // Lưu trữ truy vấn tìm kiếm
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _getCartItemCount();
  }

  Future<void> _getCartItemCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final QuerySnapshot cartSnapshot =
          await shoppingCart.doc(currentUser.email).collection('items').get();
      setState(() {
        cartItemCount = cartSnapshot.docs.length;
      });
    }
  }

  Future<void> addToCart(DocumentSnapshot documentSnapshot) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey('value')) {
        final cartItem = await shoppingCart
            .doc(currentUser.email)
            .collection('items')
            .where('name', isEqualTo: data['name'])
            .get();

        if (cartItem.docs.isEmpty) {
          await shoppingCart.doc(currentUser.email).collection('items').add({
            'name': data['name'],
            'value': data['value'], // Thay thế price bằng value
            'image': data['image'],
            'quantity': 1,
          });
          _getCartItemCount();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game added to cart')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You have already added this game to the cart')),
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

  Future<bool> isPurchased(String gameName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final QuerySnapshot purchasedGames = await FirebaseFirestore.instance
          .collection("userLibrary")
          .doc(currentUser.email)
          .collection("games")
          .where('name', isEqualTo: gameName)
          .get();
      return purchasedGames.docs.isNotEmpty;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blueGrey[500],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
        actions: [
          const SizedBox(width: 35),
          const Spacer(),
          Text(
            "Tất Cả Sản Phẩm",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[300],
            ),
          ),
          const Spacer(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            mySearchBar(), // Thanh tìm kiếm
            const SizedBox(height: 10),
            StreamBuilder(
              stream: (searchQuery.isEmpty)
                  ? completeApp.snapshots()
                  : completeApp
                      .where('name', isGreaterThanOrEqualTo: searchQuery)
                      .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff')
                      .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return FutureBuilder<bool>(
                        future: isPurchased(documentSnapshot['name']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final isGamePurchased = snapshot.data ?? false;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            color: Colors.blueGrey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      documentSnapshot['image'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          documentSnapshot['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "${documentSnapshot['value']} \$",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(
                                              Iconsax.star1,
                                              color: Colors.amberAccent,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              documentSnapshot['rate']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Text("/5  "),
                                            const SizedBox(width: 5),
                                            Text(
                                              "${documentSnapshot['reviews'].toString()} Reviews",
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: isGamePurchased
                                                  ? null
                                                  : () {
                                                      addToCart(
                                                          documentSnapshot);
                                                    },
                                              icon: Text(
                                                isGamePurchased
                                                    ? 'Đã mua'
                                                    : 'Mua hàng',
                                                style: TextStyle(
                                                  color: isGamePurchased
                                                      ? Colors.grey[300]
                                                      : Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                provider.toggleFavorite(
                                                    documentSnapshot);
                                              },
                                              icon: Icon(
                                                provider.isExist(
                                                        documentSnapshot)
                                                    ? Iconsax.heart5
                                                    : Iconsax.heart,
                                                color: provider.isExist(
                                                        documentSnapshot)
                                                    ? Colors.red
                                                    : Colors.black,
                                                size: 22,
                                              ),
                                            ),
                                          ],
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
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CartScreen(),
                ),
              );
            },
            child: const Icon(Iconsax.shopping_cart),
          ),
          if (cartItemCount > 0)
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$cartItemCount',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Padding mySearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim(); // Cập nhật truy vấn tìm kiếm
          });
        },
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal),
          fillColor: Colors.grey[400],
          border: InputBorder.none,
          hintText: "Tìm mọi loại games",
          hintStyle: TextStyle(
            color: Colors.black45,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
