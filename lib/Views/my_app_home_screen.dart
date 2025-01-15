import 'package:finall/Views/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../Provider/favorite_provider.dart';
import '../Utils/constain.dart';
import '../widget/banner.dart';
import '../widget/food_items_display.dart';
import '../widget/my_icon_button.dart';
import 'explore_screen.dart';
import 'view_all_items.dart';

class MyAppHomeScreen extends StatefulWidget {
  const MyAppHomeScreen({super.key});

  @override
  State<MyAppHomeScreen> createState() => _MyAppHomeScreenState();
}

class _MyAppHomeScreenState extends State<MyAppHomeScreen> {
  String category = "All";
  String searchKeyword = ""; // Biến lưu từ khóa tìm kiếm

  // Firestore queries
  final CollectionReference categoriesItems =
      FirebaseFirestore.instance.collection("App-Category");

  Query get fileteredRecipes => FirebaseFirestore.instance
      .collection("Complete-Flutter-App")
      .where('category', isEqualTo: category);

  Query get allRecipes =>
      FirebaseFirestore.instance.collection("Complete-Flutter-App");

  Query get selectedRecipes =>
      category == "All" ? allRecipes : fileteredRecipes;

  Query get searchResults => FirebaseFirestore.instance
      .collection("Complete-Flutter-App")
      .where('name', isGreaterThanOrEqualTo: searchKeyword)
      .where('name', isLessThanOrEqualTo: "$searchKeyword\uf8ff");

  Query get finalQuery =>
      searchKeyword.isNotEmpty ? searchResults : selectedRecipes;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoriteProvider>(context);
    final cartItemsCount = provider.favorites.length;

    return Scaffold(
      backgroundColor: Colors.blueGrey[500],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerParts(),
                    searchBar(), // Gọi hàm tạo thanh tìm kiếm
                    const BannerToExplore(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "Danh Mục",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],                        ),
                      ),
                    ),
                    selectedCategory(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Quick & Easy",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 0.1,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ViewAllItems(),
                              ),
                            );
                          },
                          child: const Text(
                            "View all",
                            style: TextStyle(
                              color: kbannerColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: finalQuery.snapshots(), // Sử dụng truy vấn cuối cùng
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final List<DocumentSnapshot> recipes =
                        snapshot.data?.docs ?? [];
                    return Padding(
                      padding: const EdgeInsets.only(top: 5, left: 15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: recipes
                              .map((e) => FoodItemsDisplay(documentSnapshot: e))
                              .toList(),
                        ),
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // Thanh tìm kiếm
  Padding searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchKeyword = value.trim(); // Cập nhật từ khóa tìm kiếm
          });
        },
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal),
          fillColor: Colors.grey[400],
          border: InputBorder.none,
          hintText: "Tìm mọi loại games",
          hintStyle: const TextStyle(
            color: Colors.black45,
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // Header phần đầu
  Row headerParts() {
    return Row(
      children: [
        const Text(
          "Bạn muốn\nchơi gì hôm nay?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const Spacer(),
        MyIconButton(
          icon: Iconsax.profile_circle,
          pressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // Các danh mục được chọn
  StreamBuilder<QuerySnapshot<Object?>> selectedCategory() {
    return StreamBuilder(
      stream: categoriesItems.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        if (streamSnapshot.hasData) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                streamSnapshot.data!.docs.length,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      category = streamSnapshot.data!.docs[index]['name'];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color:
                          category == streamSnapshot.data!.docs[index]['name']
                              ? kprimaryColor
                              : Colors.grey[300],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.only(right: 10),
                    child: Text(
                      streamSnapshot.data!.docs[index]['name'],
                      style: TextStyle(
                        color:
                            category == streamSnapshot.data!.docs[index]['name']
                                ? Colors.grey[300]
                                : Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
