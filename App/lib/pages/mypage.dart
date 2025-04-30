import 'package:app/pages/likepage.dart';
import 'package:app/widgets/memoinputcard.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final String userName = '화려한 식객_84866';

  final List<Map<String, String>> savedRestaurants = [
    {
      'name': '려庵 프리미엄',
      'description': '리츠칼튼호텔 15년 경력. 하나조노 출신 손재용셰프의 오마카세 스시야',
      'imageUrl': 'assets/images/dummy_image/sushi.png',
      'rating': '4.8',
      'reviewCount': '1,231',
      'category': '스시오마카세',
      'location': '강남',
      'lunchPrice': '7만원',
      'dinnerPrice': '14만원',
    },
    {
      'name': '브레드포레스트',
      'description': '천연발효종으로 만든 수제 빵, 브런치 카페',
      'imageUrl': 'assets/images/dummy_image/japanese_food.png',
      'rating': '4.6',
      'reviewCount': '542',
      'category': '브런치카페',
      'location': '성수',
      'lunchPrice': '1.5만원',
      'dinnerPrice': '2.5만원',
    },
    {
      'name': '오니기리 전문점',
      'description': '간편하고 맛있는 오니기리 전문 테이크아웃 샵',
      'imageUrl': 'assets/images/dummy_image/sushi.png',
      'rating': '4.7',
      'reviewCount': '350',
      'category': '일식 · 테이크아웃',
      'location': '홍대입구',
      'lunchPrice': '0.8만원',
      'dinnerPrice': '1만원',
    },
  ];

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToLikePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LikesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '마이페이지',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Pretendard', // ✅ 패밀리명만 써야 함
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.notifications, color: Colors.black),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.settings, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontFamily: 'Pretendard', // ✅ 패밀리명만 써야 함
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '이메일 없음',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSnackbar('프로필 수정 눌림'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFD1D1D6),
                        width: 1,
                      ),
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('프로필 수정'),
                  ),
                ),
                const SizedBox(width: 12), // 버튼 사이 간격
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSnackbar('쿠폰함 열기'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFD1D1D6),
                        width: 1,
                      ),
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('쿠폰함'),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
            Divider(height: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '저장한 레스토랑 ${savedRestaurants.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _navigateToLikePage(),
                  child: Text('전체보기'),
                ),
              ],
            ),
            // 더미 레스토랑 데이터 출력
            ...savedRestaurants.map((restaurant) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            restaurant['imageUrl']!,
                            width: 70,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  width: 70,
                                  height: 90,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant['name']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant['description']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${restaurant['rating']} ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '(${restaurant['reviewCount']})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${restaurant['category']} · ${restaurant['location']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '점심 ${restaurant['lunchPrice']} · 저녁 ${restaurant['dinnerPrice']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.bookmark, color: Colors.red),
                          onPressed: () {}, // 즐겨찾기 삭제/저장
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MemoInputCard(memoKey: restaurant['name']!),
                    // 메모 입력 카드
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
