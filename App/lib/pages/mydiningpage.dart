import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/dummy_completed_info.dart';

class MyDiningPage extends StatefulWidget {
  @override
  _MyDiningPageState createState() => _MyDiningPageState();
}

class _MyDiningPageState extends State<MyDiningPage> {
  int _selectedCategory = 0;
  final List<String> categories = ['방문예정', '방문완료', '예약취소'];
  Map<int, int> starRatings = {}; // 각 예약 ID에 대한 별점 저장

  List<Map<String, dynamic>> reservations = [];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    try {
      final uuid = Supabase.instance.client.auth.currentUser?.id;
      if (uuid == null) return;

      final response = await Supabase.instance.client
          .from('reserve_data')
          .select()
          .eq('uuid', uuid);

      final List<Map<String, dynamic>> fetched =
          List<Map<String, dynamic>>.from(response);

      final enriched = await Future.wait(
        fetched.map((reservation) async {
          final bId = reservation['b_id'];

          final business =
              await Supabase.instance.client
                  .from('business_data')
                  .select()
                  .eq('id', bId)
                  .maybeSingle();

          print(
            '\uD83C\uDFE2 b_id: $bId -> 사업체: ${business?['name']} (${business?['id']})',
          );

          final enrichedReservation = Map<String, dynamic>.from(
            reservation,
          ); // ✅ 깊은 복사
          enrichedReservation['storeName'] = business?['name'];
          enrichedReservation['storeImage'] = business?['image'];
          enrichedReservation['category'] = business?['category'];
          enrichedReservation['location'] = business?['location'];

          return enrichedReservation;
        }),
      );

      print('\n✅ 최종 enriched 예약 목록:');
      for (var r in enriched) {
        final dDay =
            DateTime.tryParse(r['date'])?.difference(DateTime.now()).inDays;
        print(
          '예약 ID: ${r['id']} | ${r['storeName']} | 날짜: ${r['date']} | D-$dDay | status: ${r['status']}',
        );
      }

      enriched.sort((a, b) {
        final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime(2100);
        final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime(2100);
        return aDate.compareTo(bDate);
      });

      setState(() {
        reservations = enriched;
      });
    } catch (e) {
      print('❌ 예약 가져오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        reservations.where((r) {
          final status = r['status'];
          if (_selectedCategory == 0) return status == 'standby';
          if (_selectedCategory == 1) return status == 'approve';
          if (_selectedCategory == 2) return status == 'cancel';
          return false;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
                  automaticallyImplyLeading: false, // <-- 이 줄을 추가

        backgroundColor: Colors.white,
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
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
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
              if (_selectedCategory == 2) {
                return _buildCanceledCard(data);
              } else {
                return _selectedCategory == 1
                    ? _buildCompletedCard(data)
                    : _buildReservationCard(data);
              }
            }).toList(),
        ],
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
    final storeName = data['storeName'] ?? '가게 이름';
    final imageUrl =
        data['storeImage'] ?? 'https://example.com/default-image.png';
    final category = data['category'] ?? '중식';
    final location = data['location'] ?? '코엑스';
    final dateStr = data['date'] ?? '';
    final time = data['time'] ?? '';
    final count = data['count']?.toString() ?? '0';
    final businessId = data['b_id'];

    final now = DateTime.now();
    final date = DateTime.tryParse(dateStr);
    final dDay = (date != null) ? date.difference(now).inDays : null;

    return GestureDetector(
      onTap: () async {
        final business =
            await Supabase.instance.client
                .from('business_data')
                .select()
                .eq('id', businessId)
                .maybeSingle();

        if (business != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      StoreDetailPage(store: business_data.fromMap(business)),
            ),
          );

          await _fetchReservations();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('가게 정보를 불러올 수 없습니다.')));
        }
      },
      child: Card(
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
                  if (dDay != null) _buildBadge('D-$dDay', color: Colors.red),
                  const SizedBox(width: 6),
                  _buildBadge(
                    '예약',
                    color: Colors.grey[200]!,
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
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$category · $location',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '$dateStr · $time · $count명',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '초대장 보내기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
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
            Text(
              data['storeName'] ?? '가게 이름',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${data['date']} · ${data['time']} · ${data['count']}명',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(
              height: 24,
              color: Color.fromARGB(255, 229, 229, 229),
            ),
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
                  child: Image.network(
                    data['storeImage'] ?? '',
                    width: 55,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                          width: 55,
                          height: 70,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
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
                        '${data['date']} · ${data['time']} · ${data['count']}명',
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
