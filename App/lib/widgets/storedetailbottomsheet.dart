import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';
import 'package:flutter/material.dart';

class StoreDetailBottomSheet extends StatelessWidget {
  final String name;
  final String address;
  final business_data? store;
  final List<business_data>? recommendedStores;

  const StoreDetailBottomSheet({
    super.key,
    required this.name,
    required this.address,
    this.store,
    this.recommendedStores,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 20),
            children: [
              // 🪝 바텀시트 핸들
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              if (store != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: StoreCard(
                    store: store!,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreDetailPage(store: store!),
                        ),
                      );
                    },
                  ),
                )
              else if (recommendedStores != null)
                Column(
                  children: [
                    const SizedBox(height: 8),

                    // 🌍 지역 뱃지 + 타이틀 + 설명
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recommendedStores!.first.address.split(" ").take(2).join(" ")
,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: ' ',
                                style: TextStyle(letterSpacing: 8),
                              ),
                              TextSpan(
                                text: '가치가게 ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                              TextSpan(
                                text: '추천 ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: const Color(0xFFEDEDED),
                          ),
                        ),
                      ],
                    ),

                    Padding(
  padding: const EdgeInsets.symmetric( horizontal: 23),
  child: Row(
    children: [
    
      // 오른쪽: 설명 텍스트들
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Text(
              '현재 시간대 ',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            Text(
              '500m ',
              style: TextStyle(fontSize: 15, color: Colors.blue),
            ),
            Text(
              '반경 ',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
            Text(
              '추천순',
              style: TextStyle(fontSize: 15, color: Colors.blue),
            ),
          ],
        ),
      ),
    ],
  ),
)
,

                    // 구분선
                    const SizedBox(height: 12),

                    // 추천 매장 리스트
                    ...recommendedStores!.map(
                      (s) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        child: StoreCard(
                          store: s,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StoreDetailPage(store: s),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
