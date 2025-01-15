import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class QuantityIncrementDecrement extends StatelessWidget {
  final int currentNumber;
  final Function() onAdd;
  final Function() onRemove;
  final bool isPurchased; // Add this line
  const QuantityIncrementDecrement({
    super.key,
    required this.currentNumber,
    required this.onAdd,
    required this.onRemove,
    this.isPurchased = false, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.5,
          color: Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isPurchased) // Add this block
            const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          if (!isPurchased) // Add this block
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Iconsax.minus),
            ),
          const SizedBox(width: 10),
          Text(
            "$currentNumber",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          if (!isPurchased) // Add this block
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Iconsax.add),
            ),
        ],
      ),
    );
  }
}
