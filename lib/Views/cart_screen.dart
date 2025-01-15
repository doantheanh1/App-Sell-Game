import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference shoppingCart =
  FirebaseFirestore.instance.collection("shopping-cart");
  final CollectionReference userLibrary =
  FirebaseFirestore.instance.collection("userLibrary");

  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotalPrice();
  }

  Future<void> _calculateTotalPrice() async {
    if (currentUser != null) {
      final QuerySnapshot cartSnapshot =
      await shoppingCart.doc(currentUser!.email).collection('items').get();
      double total = 0;
      for (var item in cartSnapshot.docs) {
        total += (item['value'] is num
            ? item['value']
            : double.parse(item['value'])) *
            (item['quantity'] is num
                ? item['quantity']
                : double.parse(item['quantity']));
      }
      setState(() {
        totalPrice = total;
      });
    }
  }

  Future<void> _removeItem(String itemId) async {
    if (currentUser != null) {
      await shoppingCart
          .doc(currentUser!.email)
          .collection('items')
          .doc(itemId)
          .delete();
      _calculateTotalPrice();
    }
  }

  Future<void> _checkout() async {
    if (currentUser != null) {
      final QuerySnapshot cartSnapshot =
      await shoppingCart.doc(currentUser!.email).collection('items').get();
      for (var item in cartSnapshot.docs) {
        await userLibrary.doc(currentUser!.email).collection('games').add({
          ...item.data() as Map<String, dynamic>,
          'status': 'Chưa thanh toán'
        });
        await item.reference.delete();
      }
      _calculateTotalPrice();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán thành công')),
      );
      Navigator.pop(context); // Quay lại màn hình trước đó sau khi thanh toán
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        backgroundColor: Colors.grey[350],
      ),
      body: currentUser == null
          ? const Center(
          child: Text('Vui lòng đăng nhập để xem giỏ hàng của bạn'))
          : StreamBuilder<QuerySnapshot>(
        stream: shoppingCart
            .doc(currentUser!.email)
            .collection('items')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child:
                Text("Không thể tải các sản phẩm trong giỏ hàng."));
          }

          if (snapshot.hasData) {
            final cartItems = snapshot.data!.docs;
            if (cartItems.isEmpty) {
              return const Center(child: Text("Giỏ hàng của bạn trống."));
            }

            double total = 0;
            for (var item in cartItems) {
              total += (item['value'] is num
                  ? item['value']
                  : double.parse(item['value'])) *
                  (item['quantity'] is num
                      ? item['quantity']
                      : double.parse(item['quantity']));
            }
            totalPrice = total;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Image.network(
                            item['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(item['name']),
                          subtitle: Text("Price: ${item['value']} \$"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _removeItem(item.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Total: \$${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận thanh toán'),
                              content: const Text(
                                  'Bạn có chắc chắn muốn tiến hành thanh toán không?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _checkout();
                                  },
                                  child: const Text('Xác nhận'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text("Tiến hành thanh toán"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return const Center(
              child: Text("Đã xảy ra lỗi không mong muốn."));
        },
      ),
    );
  }
}
