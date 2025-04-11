import 'package:app/services/getstorestate.dart';
import 'package:flutter/material.dart';
import '../models/business.dart';

class StoreCard extends StatefulWidget {
  final business_data store;
  final VoidCallback onTap;

  const StoreCard({required this.store, required this.onTap});

  @override
  _StoreCardState createState() => _StoreCardState();
}

class _StoreCardState extends State<StoreCard> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              store.name,
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? const Color.fromARGB(255, 255, 85, 0) : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  isBookmarked = !isBookmarked;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.star, color: Color.fromARGB(255, 238, 200, 49), size: 20),
                            SizedBox(width: 2),
                            Text(
                              "4.7",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'pretendard',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text(
                              "(220) • ",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'pretendard',
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                store.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'pretendard',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
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
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 180,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey, size: 16),
                        SizedBox(width: 4),
                        Text(
                          getStoreStatus(store.time),
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 3, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }
}
