import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';
import 'package:flutter/material.dart';

class StoreDetailBottomSheet extends StatelessWidget {
  final String name;
  final String address;
  final business_data? store;

  const StoreDetailBottomSheet({
    Key? key,
    required this.name,
    required this.address,
    this.store,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 회색 바
            Center(
              child: Container(
                height: 4,
                width: 30,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),

              child:
              // StoreCard
              StoreCard(
                store:
                    store ??
                    business_data(
                      id: -1,
                      name: name,
                      address: address,
                      image: '',
                      time: '정보 없음',
                      lat: '',
                      lng: '',
                      number: '',
                      description: '',
                      url: '',
                    ),
                onTap: () {
                  Navigator.pop(context);
                  if (store != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StoreDetailPage(store: store!),
                      ),
                    );
                  }
                },
              ),
            ),
            // 아이콘 Row - 작고 깔끔하게
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.phone, size: 17),
                    onPressed: () {
                      // 전화 기능
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.favorite_border, size: 17),
                    onPressed: () {
                      // 즐겨찾기 기능
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share, size: 17),
                    onPressed: () {
                      // 공유 기능
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
