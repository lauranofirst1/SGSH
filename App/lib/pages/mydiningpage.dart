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
  final PageController _pageController = PageController();

  List<Map<String, dynamic>> reservations = [];

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  bool _didFetchOnDependencies = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchOnDependencies) {
      _didFetchOnDependencies = true;
      return;
    }
    print('[디버그] didChangeDependencies에서 _fetchReservations 호출!');
    // 화면에 다시 진입할 때마다 새로고침
    _fetchReservations();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedCategory = index;
    });
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchReservations() async {
    print('[디버그] _fetchReservations 실행');
    try {
      final uuid = Supabase.instance.client.auth.currentUser?.id;
      if (uuid == null) return;

      final response = await Supabase.instance.client
          .from('reserve_data')
          .select()
          .eq('uuid', uuid);

      print('[디버그] Supabase에서 받아온 예약 데이터: $response');
      final List<Map<String, dynamic>> fetched =
          List<Map<String, dynamic>>.from(response);

      final enriched = await Future.wait(
        fetched.map((reservation) async {
          final bId = reservation['b_id'];
          final now = DateTime.now();
          final reservationDate = DateTime.tryParse(reservation['date'] ?? '');
          
          // 예약 날짜가 지났고 상태가 'standby'인 경우 'cancel'로 업데이트
          if (reservationDate != null && 
              reservationDate.isBefore(now) && 
              reservation['status'] == 'standby') {
            await Supabase.instance.client
                .from('reserve_data')
                .update({'status': 'cancel'})
                .eq('id', reservation['id']);
            reservation['status'] = 'cancel';
          }

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
        print('[디버그] setState로 reservations 갱신: ${reservations.length}개');
      });
    } catch (e) {
      print('❌ 예약 가져오기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = reservations.where((r) {
          final status = r['status'];
          if (_selectedCategory == 0) return status == 'standby';
          if (_selectedCategory == 1) return status == 'approve';
          if (_selectedCategory == 2) return status == 'cancel';
          return false;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '나의 예약',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
            letterSpacing: -1.1,
          ),
        ),
        foregroundColor: Color(0xFF222222),
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                Expanded(
                  child: _tabPill(
                    emoji: '⏰',
                    label: '방문',
                    count: reservations.where((r) => r['status'] == 'standby').length,
                    selected: _selectedCategory == 0,
                    color: Colors.black,
                    onTap: () => _onTabTapped(0),
                        ),
                      ),
                SizedBox(width: 0),
                Expanded(
                  child: _tabPill(
                    emoji: '✅',
                    label: '완료',
                    count: reservations.where((r) => r['status'] == 'approve').length,
                    selected: _selectedCategory == 1,
                    color: Colors.black,
                    onTap: () => _onTabTapped(1),
                  ),
                ),
                SizedBox(width: 0),
                Expanded(
                  child: _tabPill(
                    emoji: '❌',
                    label: '취소',
                    count: reservations.where((r) => r['status'] == 'cancel').length,
                    selected: _selectedCategory == 2,
                    color: Colors.black,
                    onTap: () => _onTabTapped(2),
                        ),
                      ),
                    ],
                  ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildReservationList(0),
                _buildReservationList(1),
                _buildReservationList(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationList(int category) {
    final filtered = reservations.where((r) {
      final status = r['status'];
      if (category == 0) return status == 'standby';
      if (category == 1) return status == 'approve';
      if (category == 2) return status == 'cancel';
      return false;
    }).toList();

    return RefreshIndicator(
      onRefresh: _fetchReservations,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text(
                  '예약 내역이 없습니다.',
                  style: TextStyle(fontSize: 15, color: Color(0xFFB0B0B0)),
                ),
              ),
            )
          else
            ...filtered.map((data) {
              if (category == 2) {
                return _buildCanceledCard(data);
              } else {
                return category == 1
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (color != Colors.transparent)
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 주소에서 시/군/구만 추출 (예: '강원 춘천시 ...' → '춘천')
  String extractRegion(String address) {
    final parts = address.split(' ');
    if (parts.length >= 2) {
      return parts[1].replaceAll(RegExp(r'시|군|구'), '');
    }
    return address;
  }

  // 태그 최대 2개만 출력, 없으면 빈 문자열
  String formatTags(dynamic tags) {
    if (tags == null) return '';
    if (tags is String) {
      final tagList = tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (tagList.isEmpty) return '';
      return tagList.take(2).map((t) => '#$t').join(' ');
    }
    if (tags is List) {
      if (tags.isEmpty) return '';
      return tags.take(2).map((t) => '#$t').join(' ');
    }
    return '';
  }

  Widget _buildReservationCard(Map<String, dynamic> data) {
    final storeName = data['storeName'] ?? '가게 이름';
    final imageUrl =
        data['storeImage'] ?? 'https://example.com/default-image.png';
    final address = data['address'] ?? '';
    final tags = data['tags'] ?? [];
    final region = extractRegion(address);
    final tagStr = formatTags(tags);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        margin: const EdgeInsets.only(bottom: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (dDay != null)
                    _buildBadge(
                      dDay == 0
                          ? 'D-day'
                          : dDay > 0
                              ? 'D-${dDay}'
                              : 'D+${dDay.abs()}',
                      color: Colors.red,
                    ),
                  const SizedBox(width: 6),
                  _buildBadge(
                    '예약',
                    color: Colors.grey[200]!,
                    textColor: Colors.black,
                  ),
                  const Spacer(),
                  if (data['status'] == 'standby')
                    OutlinedButton(
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(
                              '예약 취소',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              '정말 예약을 취소하시겠습니까?',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text(
                                  '아니오',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text(
                                  '예',
                                  style: TextStyle(
                                    color: Color(0xFFE53935),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (result == true) {
                          await Supabase.instance.client
                              .from('reserve_data')
                              .update({'status': 'cancel'})
                              .eq('id', data['id']);
                          await _fetchReservations();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFE53935),
                        side: BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        minimumSize: Size(0, 24),
                        textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel, size: 12, color: Color(0xFFE53935)),
                          SizedBox(width: 2),
                          Text('예약 취소', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
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
                          (() {
                            final address = data['address'] ?? '';
                            final region = extractRegion(address);
                            final tags = data['tags'] ?? [];
                            final tagList = (tags is String)
                                ? tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                                : (tags is List ? tags : []);
                            final tagStr = tagList.isNotEmpty
                                ? tagList.take(3).join(', ')
                                : '';
                            return tagStr.isNotEmpty ? '$region | $tagStr' : region;
                          })(),
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
              const SizedBox(height: 10),
              Center(
                child: Text(
                  '방문을 잊지 마세요!',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
    final businessId = data['b_id'];
    final address = data['address'] ?? '';
    final tags = data['tags'] ?? [];
    final region = extractRegion(address);
    final tagStr = formatTags(tags);

    return GestureDetector(
      onTap: () async {
        final business = await Supabase.instance.client
            .from('business_data')
            .select()
            .eq('id', businessId)
            .maybeSingle();

        if (business != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreDetailPage(store: business_data.fromMap(business)),
            ),
          );
        }
      },
      child: Card(
      color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildBadge(
                    '완료',
                    color: Color(0xFF43A047),
                    textColor: Colors.white,
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
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data['storeImage'] ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
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
              data['storeName'] ?? '가게 이름',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
                        Text(
                          (() {
                            final address = data['address'] ?? '';
                            final region = extractRegion(address);
                            final tags = data['tags'] ?? [];
                            final tagList = (tags is String)
                                ? tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                                : (tags is List ? tags : []);
                            final tagStr = tagList.isNotEmpty
                                ? tagList.take(3).join(', ')
                                : '';
                            return tagStr.isNotEmpty ? '$region | $tagStr' : region;
                          })(),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildCanceledCard(Map<String, dynamic> data) {
    final businessId = data['b_id'];
    final address = data['address'] ?? '';
    final tags = data['tags'] ?? [];
    final region = extractRegion(address);
    final tagStr = formatTags(tags);
    
    return GestureDetector(
      onTap: () async {
        final business = await Supabase.instance.client
            .from('business_data')
            .select()
            .eq('id', businessId)
            .maybeSingle();

        if (business != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreDetailPage(store: business_data.fromMap(business)),
            ),
          );
        }
      },
      child: Card(
      color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
        margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
          padding: const EdgeInsets.all(20),
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
                        (() {
                          final address = data['address'] ?? '';
                          final region = extractRegion(address);
                          final tags = data['tags'] ?? [];
                          final tagList = (tags is String)
                              ? tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
                              : (tags is List ? tags : []);
                          final tagStr = tagList.isNotEmpty
                              ? tagList.take(3).join(', ')
                              : '';
                          return tagStr.isNotEmpty ? '$region | $tagStr' : region;
                        })(),
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
      ),
    );
  }

  Widget _tabPill({
    required String emoji,
    required String label,
    required int count,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(
                    fontFamily: 'TossFace',
                    fontSize: 16,
                    color: selected ? color : Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '$label $count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selected ? color : Colors.grey,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.ease,
              width: 32,
              height: 2,
              decoration: BoxDecoration(
                color: selected ? color : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
