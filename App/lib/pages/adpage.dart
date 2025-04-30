import 'package:flutter/material.dart';

class MyDiningPage extends StatefulWidget {
  @override
  _MyDiningPageState createState() => _MyDiningPageState();
}

class _MyDiningPageState extends State<MyDiningPage> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이다이닝', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: Text('나의 예약', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: Text('나의 알림', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // 카테고리 탭
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryTab('방문예정', true),
              _buildCategoryTab('방문완료', false, hasDot: true),
              _buildCategoryTab('취소/노쇼', false),
            ],
          ),
          SizedBox(height: 20),

          // 예약 카드
          _buildReservationCard(),

          SizedBox(height: 20),

          // 하단 안내
          ListTile(
            tileColor: Colors.grey[100],
            title: Text('전화예약 캐치테이블 앱으로 연동하기'),
            subtitle: Text('전화로 한 예약도 앱에서 확인할 수 있어요!'),
            trailing: Icon(Icons.chevron_right),
          )
        ],
      ),
     
    );
  }

  Widget _buildCategoryTab(String title, bool selected, {bool hasDot = false}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.black : Colors.grey,
          ),
        ),
        if (hasDot)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CircleAvatar(radius: 3, backgroundColor: Colors.red),
          ),
      ],
    );
  }

  Widget _buildReservationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // D-Day, 예약 태그
            Row(
              children: [
                _buildBadge('D-19'),
                SizedBox(width: 8),
                _buildBadge('예약', color: Colors.grey[300]!, textColor: Colors.black),
              ],
            ),
            SizedBox(height: 12),
            // 식당 정보
            Row(
              children: [
                Image.network(
'',                  width: 40,
                  height: 40,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('하이디라오 코엑스점', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('중식 · 코엑스', style: TextStyle(color: Colors.grey)),
                    Text('2025.05.18 (일) · 오후 12:30 · 3명',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            SizedBox(height: 12),
            // 초대장 배너
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.mail, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('가정의 달을 맞아 새로운 초대장을 보내보세요!',
                        style: TextStyle(color: Colors.white)),
                  ),
                  Icon(Icons.close, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: Text('초대장 보내기'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, {Color color = Colors.red, Color textColor = Colors.white}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
    );
  }
}
