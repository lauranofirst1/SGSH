import 'package:app/models/userprofile.dart';
import 'package:app/pages/likepage.dart';
import 'package:app/setting/settings_page.dart';
import 'package:app/services/bookmark_service.dart';
import 'package:app/models/business.dart';
import 'package:app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/memoinputcard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/pages/storedetail.dart'; // ✅ StoreDetailPage import 추가

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // final String userName = '화려한 식객_84866';
  List<business_data> bookmarkedStores = [];
  UserProfile? currentUserProfile;

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
  void initState() {
    super.initState();
    loadUserProfile(); // ✅ 추가
    loadBookmarkedStores();
  }

  Future<void> loadUserProfile() async {
  UserProfile? profile = await SupabaseService().getUserProfile();

  if (profile?.code == null) {
    final randomCode = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();

    // 중복 방지: 해당 코드가 이미 존재하는지 확인
    final isDuplicate = await Supabase.instance.client
        .from('profile_data')
        .select('code')
        .eq('code', randomCode)
        .maybeSingle();

    if (isDuplicate == null) {
      // Supabase에 랜덤 코드 저장
      await Supabase.instance.client
          .from('profile_data')
          .update({'code': randomCode})
          .eq('id', profile!.id);

      // 메모리에 반영
      profile = UserProfile(
        id: profile.id,
        email: profile.email,
        point: profile.point,
        bId: profile.bId,
        code: randomCode, // ✅ 제대로 전달
      );
    }
  }

  setState(() {
    currentUserProfile = profile;
  });
  print('👤 사용자 코드: ${profile?.code}');

}



  Future<void> loadBookmarkedStores() async {
    final allStores = await fetchAllStores();
    final ids = await BookmarkService.getBookmarkedIds();

    setState(() {
      bookmarkedStores =
          allStores
              .where((store) => ids.contains(store.id.toString()))
              .toList();
    });
  }

  Future<List<business_data>> fetchAllStores() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('business_data')
          .select()
          .order('id', ascending: true);

      if (response.isEmpty) return [];

      return response
          .map<business_data>((data) => business_data.fromMap(data))
          .toList();
    } catch (e) {
      print("❌ [fetchAllStores] 에러 발생: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
                  automaticallyImplyLeading: false, // <-- 이 줄을 추가

        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => _showSnackbar('알림 설정 이동'),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              _showSnackbar('설정 이동');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),
                const SizedBox(width: 10),
                Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      currentUserProfile?.email ?? '로그인 유저 없음',
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    ),
    const SizedBox(height: 5),
    Text(
      '포인트 : ${currentUserProfile?.point ?? 0}p',
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    ),
    Text(
      '코드: ${currentUserProfile?.code ?? '없음'}',
      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
    ),
  ],
),

              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSnackbar('프로필 수정 눌림'),
                    child: const Text('프로필 수정'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSnackbar('쿠폰함 열기'),
                    child: const Text('쿠폰함'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '저장한 레스토랑 ${bookmarkedStores.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _navigateToLikePage,
                  child: const Text('전체보기'),
                ),
              ],
            ),

            // ✅ 북마크 레스토랑 리스트
            ...bookmarkedStores.map((store) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoreDetailPage(store: store),
                    ),
                  );
                },
                child: Container(
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
                            child: Image.network(
                              store.image,
                              width: 70,
                              height: 90,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70,
                                  height: 90,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image, color: Colors.white),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  store.description,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '4.7',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '(220)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  store.address,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Text(
                                  '점심 1.5만원 · 저녁 2.5만원',
                                  style: TextStyle(
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
                            onPressed: () async {
                              await BookmarkService.toggleBookmark(
                                store.id.toString(),
                              );
                              // 북마크 ID만 최신화
                              

                              setState(() {
                                        loadBookmarkedStores();

                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MemoInputCard(memoKey: store.name),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
