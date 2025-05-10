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
      padding: const EdgeInsets.only(left: 20, right: 20, top: 14, bottom: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                  onBookmarkToggle(!isBookmarked);
              },
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: isBookmarked ? Color(0xFFFFF3F0) : Color(0xFFF8F8F8),
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                    color: isBookmarked ? Color(0xFFE53935) : Color(0xFFB0B0B0),
                  ),
                ),
                  ),
              const SizedBox(height: 2),
              Text(
                '북마크',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isBookmarked ? Color(0xFFE53935) : Color(0xFF888888),
                ),
              ),
                ],
            ),
          const SizedBox(width: 18),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            GestureDetector(
              onTap: onCallPressed,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFF8F8F8),
                  child: Icon(Icons.phone, size: 18, color: Color(0xFF888888)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '전화',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF888888)),
              ),
            ],
            ),
            const SizedBox(width: 20),
            Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onReservePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE53935),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 0),
                ),
                child: const Text(
                  '예약하기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 19,
                    letterSpacing: -0.5,
                  ),
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}
