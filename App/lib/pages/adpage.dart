
import 'package:flutter/material.dart';

class AdPage extends StatelessWidget {
  final List<Map<String, dynamic>> dummyData = [
    {
      'image': 'assets/images/adimage/img01.jpg',
      'username': '@coffee_house',
      'description': '따뜻한 라떼 한 잔 어때요?',
      'storeId': 1, // ✅ id만 저장
    },
    {
      'image': 'assets/images/adimage/img02.jpg',
      'username': '@pizza_planet',
      'description': '오늘은 피자데이!',
      'storeId': 2, // ✅ id만 저장
    },
{
      'image': 'assets/images/adimage/img03.jpg',
      'username': '@pizza_planet',
      'description': '오늘은똥데이!',
      'storeId': 2, // ✅ id만 저장
    },{
      'image': 'assets/images/adimage/img04.jpg',
      'username': '@pizza_planet',
      'description': '오늘은커피데이!',
      'storeId': 2, // ✅ id만 저장
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: dummyData.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // 배경 콘텐츠 (이미지/영상 대신 텍스트로 대체)
              Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                color: Colors.black,
                child: Image.asset(
  dummyData[index]['image'], // ✅ 고쳐야 할 부분
                  fit: BoxFit.fitWidth, // ✅ 세로 기준으로 꽉 채움
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // 오른쪽 아이콘들
              Positioned(
                right: 16,
                bottom: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, color: Colors.white, size: 32),
                    SizedBox(height: 16),
                    Icon(Icons.comment, color: Colors.white, size: 32),
                    SizedBox(height: 16),
                    Icon(Icons.share, color: Colors.white, size: 32),
                  ],
                ),
              ),
              // 하단 사용자명 + 설명
              // 하단 정보 영역
              Positioned(
                left: 16,
                bottom: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // ✅ username 누르면 해당 store로 이동
                      //  final store = dummyData[index]['store'];
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder:
                        //         (_) =>
                        //             StoreDetailPage(store: store), // 상세 페이지 연결
                        //   ),
                        // );
                      },
                      child: Text(
                        dummyData[index]['username'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      dummyData[index]['description'],
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
