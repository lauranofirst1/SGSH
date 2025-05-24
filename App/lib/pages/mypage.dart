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
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';  // StreamSubscription을 위한 import 추가

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  // final String userName = '화려한 식객_84866';
  List<business_data> bookmarkedStores = [];
  UserProfile? currentUserProfile;
  StreamSubscription? _bookmarkSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadUserProfile();
    loadBookmarkedStores();
    _subscribeToBookmarkChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bookmarkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadBookmarkedStores();
    }
  }

  @override
  void didUpdateWidget(MyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // loadBookmarkedStores(); // 불필요한 새로고침 제거
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   loadBookmarkedStores();
    // }); // 불필요한 새로고침 제거
  }

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

  void _subscribeToBookmarkChanges() {
    _bookmarkSubscription = BookmarkService.bookmarkStream.listen((ids) {
      print('📱 북마크 변경 감지: $ids');
    loadBookmarkedStores();
    });
  }

  Future<void> loadUserProfile() async {
    UserProfile? profile = await SupabaseService().getUserProfile();

    if (profile?.code == null) {
      final randomCode =
          (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();

      // 중복 방지: 해당 코드가 이미 존재하는지 확인
      final isDuplicate =
          await Supabase.instance.client
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
    print('🔄 북마크 목록 새로고침 중...');
    try {
    final allStores = await fetchAllStores();
    final ids = await BookmarkService.getBookmarkedIds();
      print('📚 북마크된 ID 목록: $ids');

      if (mounted) {
    setState(() {
          bookmarkedStores = allStores
              .where((store) => ids.contains(store.id.toString()))
              .toList();
    });
        print('✅ 북마크 목록 업데이트 완료: ${bookmarkedStores.length}개');
      }
    } catch (e) {
      print('❌ 북마크 목록 로드 실패: $e');
    }
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
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        await loadBookmarkedStores();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        centerTitle: false,
        title: const Text(
          '마이페이지',
          style: TextStyle(
              fontSize: 24,
            fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
              letterSpacing: -1.1,
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none, color: Color(0xFF222222)),
              onPressed: () {
                loadBookmarkedStores();  // 알림 버튼 클릭 시에도 새로고침
              },
          ),
          IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF222222)),
              onPressed: () async {
                await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
                loadBookmarkedStores();  // 설정 페이지에서 돌아올 때 새로고침
            },
          ),
        ],
          foregroundColor: Color(0xFF222222),
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: SafeArea(
          child: RefreshIndicator(  // 당겨서 새로고침 기능 추가
            onRefresh: loadBookmarkedStores,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Color(0xFFF0F0F0), width: 1),
                      ),
                      child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
                ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUserProfile?.email ?? '로그인 유저 없음',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF222222),
                      ),
                    ),
                          const SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars, size: 16, color: Color(0xFFFFB800)),
                                SizedBox(width: 4),
                    Text(
                                  '${currentUserProfile?.point ?? 0}p',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(20),
                    ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.qr_code, size: 16, color: Color(0xFF666666)),
                                SizedBox(width: 4),
                    Text(
                      '코드: ${currentUserProfile?.code ?? '없음'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
            
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '저장한 레스토랑 ${bookmarkedStores.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF222222),
                        ),
                ),
                TextButton(
                  onPressed: _navigateToLikePage,
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF666666),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text(
                          '전체보기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
                ),
            ...bookmarkedStores.map((store) {
              return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                          builder: (context) => StoreDetailPage(store: store),
                    ),
                  );
                      if (result == true) loadBookmarkedStores();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFF0F0F0), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              store.image,
                                    width: 80,
                                    height: 100,
                              fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                      return Container(
                                        width: 80,
                                        height: 100,
                                        color: Colors.grey[100],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF666666)),
                                          ),
                                        ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                        width: 80,
                                        height: 100,
                                        color: Colors.grey[100],
                                        child: Icon(Icons.image, color: Colors.grey[400]),
                                );
                              },
                            ),
                          ),
                                const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: const TextStyle(
                                          fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                          color: Color(0xFF222222),
                                  ),
                                ),
                                      const SizedBox(height: 6),
                                Text(
                                  store.description,
                                  style: const TextStyle(
                                          fontSize: 13,
                                    color: Color(0xFF666666),
                                          height: 1.4,
                                  ),
                                ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFF8E1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                                  color: Color(0xFFFFB800),
                                                  size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '4.7',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Color(0xFF222222),
                                      ),
                                    ),
                                    Text(
                                                  ' (220)',
                                      style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF666666),
                                                  ),
                                                ),
                                              ],
                                      ),
                                    ),
                                  ],
                                ),
                                      const SizedBox(height: 8),
                                Text(
                                  store.address,
                                  style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                  ),
                                ),
                                      const SizedBox(height: 4),
                                      Text(
                                  '점심 1.5만원 · 저녁 2.5만원',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bookmark, color: Color(0xFFE53935)),
                                  onPressed: () async {
                                    await BookmarkService.toggleBookmark(
                                      store.id.toString(),
                                    );
                                    // setState(() {
                                    //   loadBookmarkedStores();
                                    // }); // 불필요한 새로고침 제거, 스트림 알림만 사용
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: MemoInputCard(memoKey: store.name),
                          ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

