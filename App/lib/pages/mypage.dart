import 'package:app/pages/likepage.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final String userName = '화려한 식객_84866';

  // 더미 데이터: 저장한 레스토랑 리스트
  final List<Map<String, String>> savedRestaurants = [
    {
      'name': '려庵 프리미엄',
      'description': '리츠칼튼호텔 15년 경력. 하나조노 출신 손재용셰프의 오마카세 스시야',
      'imageUrl': 'assets/japanese_food.png',
      'rating': '4.8',
      'reviewCount': '1,231',
    },
    {
      'name': '브레드포레스트',
      'description': '천연발효종으로 만든 수제 빵, 브런치 카페',
      'imageUrl': 'assets/japanese_food.png',
      'rating': '4.6',
      'reviewCount': '542',
    },
    {
      'name': '오니기리 전문점',
      'description': '간편하고 맛있는 오니기리 전문 테이크아웃 샵',
      'imageUrl': 'assets/japanese_food.png',
      'rating': '4.7',
      'reviewCount': '350',
    },
  ];

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                Icon(Icons.notifications, color: Colors.black),
                Icon(Icons.settings, color: Colors.black),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                userName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            SizedBox(height: 5),
            Center(child: Text('팔로워 0 · 팔로잉 1')),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => _showSnackbar('프로필 수정 눌림'),
                  child: Text('프로필 수정'),
                ),
                OutlinedButton(
                  onPressed: () => _showSnackbar('쿠폰함 열기'),
                  child: Text('쿠폰함'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.cake, color: Colors.deepOrange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '캐치테이블이 특별한 날을 축하해드릴게요\n생일/기념일 등록하기',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text('나의 저장 ${savedRestaurants.length}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 120,
              color: Colors.black12,
              child: Center(child: Text('광고 배너 영역')),
            ),
            SizedBox(height: 20),
            Text('컬렉션 0'),
            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _showSnackbar('새 컬렉션 만들기 눌림'),
              icon: Icon(Icons.add),
              label: Text('새 컬렉션 만들기'),
            ),
            SizedBox(height: 30),
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
              return Card(
  margin: EdgeInsets.only(bottom: 10),
  child: ListTile(
    leading: SizedBox(
      width: 56,
      height: 56,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          restaurant['imageUrl']!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey,
            child: Icon(Icons.image, color: Colors.white),
          ),
        ),
      ),
    ),
    title: Text(
      restaurant['name']!,
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(restaurant['description']!),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.star, color: Colors.orange, size: 16),
        SizedBox(height: 4),
        Text('${restaurant['rating']} (${restaurant['reviewCount']})', style: TextStyle(fontSize: 12)),
      ],
    ),
  ),
)
;
            }).toList(),
          ],
        ),
      ),
     
    );
  }
}
