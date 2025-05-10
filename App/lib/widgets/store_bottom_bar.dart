import 'package:flutter/material.dart';

class StoreBottomBar extends StatelessWidget {
  final VoidCallback onReservePressed;
  final VoidCallback onCallPressed;
  final Function(bool) onBookmarkToggle; // ✅ 북마크 상태 변경 콜백
  final bool isBookmarked;

  const StoreBottomBar({
    super.key,
    required this.onReservePressed,
    required this.onCallPressed,
    required this.onBookmarkToggle,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10).copyWith(bottom: 40),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                onBookmarkToggle(!isBookmarked); // ✅ 상태 반전 전달
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 20,
                    color: Colors.black,
                  ),
                  Text('북마크', style: TextStyle(fontSize: 12)),
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
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: onReservePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
            ),
          ],
        ),
      ),
    );
  }
}
