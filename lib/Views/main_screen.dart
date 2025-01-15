import 'package:finall/Views/favorite_screen.dart';
import 'package:finall/Views/profile_screen.dart';
import 'package:finall/Views/view_all_items.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../Utils/constain.dart';
import 'my_app_home_screen.dart';
import 'library_screen.dart'; // Add LibraryScreen import

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final List<Widget> page;
  @override
  void initState() {
    page = [
      const MyAppHomeScreen(),
      const FavoriteScreen(),
      const ViewAllItems(),
      const LibraryScreen(), // Add LibraryScreen
      const ProfileScreen(),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[400],
        elevation: 0,
        iconSize: 28,
        currentIndex: selectedIndex,
        selectedItemColor: kprimaryColor,
        unselectedItemColor: Colors.grey[700],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          color: kprimaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart,
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.shop5 : Iconsax.shop,
            ),
            label: "Store",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.book_1 : Iconsax.book,
            ),
            label: "Library",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 4 ? Iconsax.user_edit4 : Iconsax.user,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: page[selectedIndex],
    );
  }

  navBarPage(iconName) {
    return Center(
      child: Icon(
        iconName,
        size: 100,
        color: kprimaryColor,
      ),
    );
  }
}
