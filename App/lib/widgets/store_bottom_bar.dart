import 'package:flutter/material.dart';

class StoreBottomBar extends StatelessWidget {
  final VoidCallback onReservePressed;
  final VoidCallback onCallPressed;
  final VoidCallback onBookmarkPressed;
  final int bookmarkCount;

  const StoreBottomBar({
    super.key,
    required this.onReservePressed,
    required this.onCallPressed,
    required this.onBookmarkPressed,
    this.bookmarkCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      child: Padding(padding : EdgeInsets.all(10).copyWith(bottom: 40), child: Row(
        children: [
          GestureDetector(
            onTap: onBookmarkPressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_border, size: 20, color: Colors.black),
                Text('$bookmarkCount', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: onCallPressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.phone, size: 20, color: Colors.black),
                Text('전화', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
SizedBox(width: 20), // ← 딱 적당한 간격 (원하면 8 또는 16으로 조절 가능)
         Expanded(
  child: ElevatedButton(
    onPressed: onReservePressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: const Text(
      '예약하기',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 16,
      ),
    ),
  ),
)

        ],
      ),) 
    );
  }
}
