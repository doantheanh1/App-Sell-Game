import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;
  final int notificationCount; // Add this line
  const MyIconButton({
    super.key,
    required this.icon,
    required this.pressed,
    this.notificationCount = 0, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            fixedSize: const Size(50, 50),
          ),
          onPressed: pressed,
          icon: Icon(icon),
        ),
        if (notificationCount > 0) // Add this block
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
                '$notificationCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
