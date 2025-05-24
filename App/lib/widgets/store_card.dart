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
    final tags = store.tags.take(2).toList();

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
                      // 이름과 태그 묶음
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: tags.map((tag) => Text(
                                '#$tag',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.deepOrange,
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked
                              ? const Color.fromARGB(255, 255, 85, 0)
                              : Colors.grey,
                        ),
                        onPressed: () async {
                          await BookmarkService.toggleBookmark(store.id.toString());
                          setState(() {
                            isBookmarked = !isBookmarked;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 평점 및 주소
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFeec831), size: 18),
                      const SizedBox(width: 2),
                      const Text(
                        "4.7",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "(220) • ",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                      ),
                      Expanded(
                        child: Text(
                          store.address,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                          overflow: TextOverflow.ellipsis,
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
