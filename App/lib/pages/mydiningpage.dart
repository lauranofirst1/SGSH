import 'package:app/widgets/store_bottom_bar.dart';
import 'package:flutter/material.dart';
import '../data/dummy_reservations.dart';
import '../data/dummy_completed_info.dart';

class MyDiningPage extends StatefulWidget {
  @override
  _MyDiningPageState createState() => _MyDiningPageState();
}

class _MyDiningPageState extends State<MyDiningPage> {
  int _selectedCategory = 0;
  final List<String> categories = ['방문예정', '방문완료', '취소/노쇼'];
  Map<int, int> starRatings = {}; // 각 예약 ID에 대한 별점 저장

  String get currentStatus {
    switch (_selectedCategory) {
      case 0:
        return 'upcoming';
      case 1:
        return 'completed';
      case 2:
        return 'canceled';
      default:
        return 'upcoming';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        reservations.where((r) => r['status'] == currentStatus).toList();

    return Scaffold(
      backgroundColor: Colors.white, // 항상 흰색 유지

      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '나의 예약',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        foregroundColor: Colors.black, // 버튼색이 스크롤에 의해 바뀌지 않도록
        surfaceTintColor: Colors.white, // 머티리얼 3 대응용 (앱바 배경 흐림 방지)
        shadowColor: Colors.transparent, // 그림자 투명화(선택)
      ),
     
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // 🔻 카테고리 탭: 작대기로 선택 상태 표현
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(categories.length, (index) {
                final bool isSelected = _selectedCategory == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = index;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        categories[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // 🔻 필터링된 카드 출력
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  '예약 내역이 없습니다.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            )
          else
            ...filtered.map((data) {
              if (_selectedCategory == 1) {
                return _buildCompletedCard(data);
              } else if (_selectedCategory == 2) {
                return _buildCanceledCard(data);
              } else {
                return _buildReservationCard(data);
              }
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTopTab(String title, bool isSelected) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.black : Colors.grey[300]!,
              width: 2,
            ),
          ),
        ),
        child: TextButton(
          onPressed: () {},
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    String text, {
    Color color = Colors.red,
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReservationCard(Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (data['status'] == 'upcoming')
                  _buildBadge('D-${data['dday']}'),
                const SizedBox(width: 8),
                _buildBadge(
                  '예약',
                  color: Colors.grey[300]!,
                  textColor: Colors.black,
                ),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined, color: Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    data['image'],
                    width: 55,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['storeName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['category']} · ${data['location']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['date']} (${data['dayOfWeek']}) · ${data['time']} · ${data['people']}명',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD1D1D6), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  '초대장 보내기',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> data) {
    final int id = data['id'];
    final completedInfo = completedInfos[id] ?? {};
    final int visitCount = completedInfo['visitCount'] ?? 1;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBadge(
                  '예약',
                  color: const Color.fromARGB(255, 243, 243, 243),
                  textColor: Colors.black,
                ),
                const SizedBox(width: 6),
                Text(
                  '총 ${visitCount}회 방문',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Icon(Icons.close, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    data['image'],
                    width: 55,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['storeName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['category']} · ${data['location']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['date']} (${data['dayOfWeek']}) · ${data['time']} · ${data['people']}명',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 24,
              color: Color.fromARGB(255, 229, 229, 229),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '별점으로 평가해주세요',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < (starRatings[id] ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      starRatings[id] = index + 1;
                    });
                  },
                );
              }),
            ),
            Center(
              child: _buildBadge(
                '잊기 전에 남겨보세요',
                color: const Color.fromARGB(255, 238, 238, 238),
                textColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanceledCard(Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBadge(
                  '취소됨',
                  color: Colors.grey[300]!,
                  textColor: Colors.black,
                ),
                const Spacer(),
                Icon(Icons.info_outline, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    data['image'],
                    width: 55,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['storeName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['category']} · ${data['location']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['date']} (${data['dayOfWeek']}) · ${data['time']} · ${data['people']}명',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 245, 245, 245),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '사정이 생겨 방문하지 못했어요',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
