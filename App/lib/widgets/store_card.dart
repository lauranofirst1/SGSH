import 'package:app/services/bookmark_service.dart';
import 'package:flutter/material.dart';
import '../models/business.dart';

class StoreCard extends StatefulWidget {
  final business_data store;
  final VoidCallback onTap;

  const StoreCard({required this.store, required this.onTap, super.key});

  @override
  _StoreCardState createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    loadBookmarkStatus();
  }

  void loadBookmarkStatus() async {
    final isMarked = await BookmarkService.isBookmarked(widget.store.id.toString());
    setState(() {
      isBookmarked = isMarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final tags = store.tags;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 정보 영역
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // 제목 + 북마크
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⬅️ 이름 + 태그 묶음
                      Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 가게 이름
          Expanded(
            flex: 1,
            child: Text(
              store.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 6),
          // 태그들
          // Expanded(
          //   flex: 2,
          //   child: Wrap(
          //     spacing: 4,
          //     runSpacing: 0,
          //     children: tags.map((tag) => Text(
          //       '#$tag',
          //       style: const TextStyle(
          //         fontSize: 13,
          //         fontWeight: FontWeight.w500,
          //         color: Colors.deepOrange,
          //       ),
          //     )).toList(),
          //   ),
          // ),
        ],
      ),
    ],
  ),
),

                      // ➡️ 북마크
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked
                                ? const Color.fromARGB(255, 255, 85, 0)
                                : Colors.grey,
                          ),
                          padding: EdgeInsets.all(0),
                          constraints: BoxConstraints(),
                          onPressed: () async {
                            await BookmarkService.toggleBookmark(store.id.toString());
                            setState(() {
                              isBookmarked = !isBookmarked;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // 평점 및 주소
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey, size: 18),
                      SizedBox(width: 6),
                      Text(
                        store.number,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          store.address,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 이미지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  store.image.isNotEmpty
                      ? store.image
                      : 'https://via.placeholder.com/400x200?text=No+Image',
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                    );
                  },
                ),
              ),
            ),

            // 영업시간
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    store.time,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // 하단 구분선
            Container(height: 3, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }
}
