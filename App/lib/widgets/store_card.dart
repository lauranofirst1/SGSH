import 'package:app/pages/storedetail.dart';
import 'package:flutter/material.dart';
import '../models/business.dart';

class StoreCard extends StatelessWidget {
  final business_data store;
  final VoidCallback onTap; // 외부에서 클릭 동작을 전달받아야 함

  const StoreCard({
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,  // ⚠️ 이 부분이 중요합니다! 외부에서 받은 onTap을 사용해야 해요.
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 20),
                      SizedBox(width: 4),
                      Text("STAR (1400)", style: TextStyle(fontSize: 14)),
                      SizedBox(width: 10),
                      Icon(Icons.location_on, color: Colors.grey, size: 18),
                      SizedBox(width: 4),
                      Text(store.address, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  store.image,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.error, color: Colors.red));
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
                  Text(store.time, style: TextStyle(fontSize: 12)),
                  SizedBox(width: 10),
                  Icon(Icons.attach_money, color: Colors.grey, size: 16),
                  SizedBox(width: 4),
                 // Text(store.price, style: TextStyle(fontSize: 12)),
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
