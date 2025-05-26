import 'package:app/models/article.dart';
import 'package:app/pages/imageviewpage.dart';
import 'package:app/services/bookmark_service.dart';
import 'package:app/widgets/menudetail_modal.dart';
import 'package:app/widgets/reservation_bottom_sheet.dart';
import 'package:app/widgets/store_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/business.dart';
import 'package:app/models/menu.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/services/slivertabbardelegate.dart';
import 'package:share_plus/share_plus.dart'; // 앱 공유

class StoreDetailPage extends StatefulWidget {
  final business_data store;

  const StoreDetailPage({super.key, required this.store});

  @override
  _StoreDetailPageState createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage>
    with SingleTickerProviderStateMixin {
  List<menu_data> menuList = [];
  List<article_data> storeArticles = []; // 🔍 스토어 전용 아티클 목록

  late Future<SharedPreferences> prefsFuture;
  final supabase = Supabase.instance.client;
  late TabController _tabController;
  bool isBookmarked = false;
  bool showTitle = false;
  static const String bookmarkKey = 'bookmarkedStores';

  void fetchStoreArticles() async {
    try {
      final response = await supabase
          .from('article_data')
          .select()
          .eq('b_id', widget.store.id) // store.id와 연결
          .eq('type', 1) // type == 1
          .order('id', ascending: false); // 원하는 정렬 방식 (ex. 최신순)

      if (response.isEmpty) return;

      setState(() {
        storeArticles =
            response
                .map<article_data>((item) => article_data.fromMap(item))
                .toList();
      });
    } catch (e) {
      print("❌ [article_data] 불러오기 실패: $e");
    }
  }

  void updateTodayHits() async {
  final today = DateTime.now();
  final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  try {
    // 이미 있는지 확인
    final existing = await supabase
        .from('business_hits')
        .select()
        .eq('b_id', widget.store.id)
        .eq('date', todayStr)
        .maybeSingle();

    if (existing != null) {
      // 이미 있으면 hits + 1
      await supabase
          .from('business_hits')
          .update({'hits': (existing['hits'] ?? 0) + 1})
          .eq('id', existing['id']);
      print('✅ 오늘 조회수 +1');
    } else {
      // 없으면 새로 생성
      await supabase.from('business_hits').insert({
        'b_id': widget.store.id,
        'date': todayStr,
        'hits': 1,
      });
      print('✅ 첫 방문 기록됨');
    }
  } catch (e) {
    print("❌ 조회수 업데이트 실패: $e");
  }
}


  void toggleBookmark() async {
    await BookmarkService.toggleBookmark(widget.store.id.toString());
    await checkBookmarkStatus(); // 북마크 상태를 정확히 다시 읽어옴

    print(
      isBookmarked
          ? "🔖 북마크 추가됨: ${widget.store.name}"
          : "❌ 북마크 해제됨: ${widget.store.name}",
    );
  }

  Future<void> checkBookmarkStatus() async {
    final isMarked = await BookmarkService.isBookmarked(
      widget.store.id.toString(),
    );
    setState(() {
      isBookmarked = isMarked;
    });
  }

  void shareStore() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '공유하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.link),
                title: Text('링크 복사'),
                onTap: () {
                  final link = widget.store.url;
                  Clipboard.setData(ClipboardData(text: link));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('링크가 복사되었습니다')));
                },
              ),
              ListTile(
                leading: Icon(Icons.open_in_browser),
                title: Text('링크 열기'),
                onTap: () async {
                  final url = Uri.parse(widget.store.url);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('기타 앱으로 공유'),
                onTap: () {
                  final text = '${widget.store.name}\n${widget.store.url}';
                  Share.share(text); // share_plus 필요
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    prefsFuture = SharedPreferences.getInstance();

    _scrollController.addListener(() {
      if (_scrollController.offset > 150 && !showTitle) {
        setState(() => showTitle = true);
      } else if (_scrollController.offset <= 150 && showTitle) {
        setState(() => showTitle = false);
      }
    });

    fetchMenuData();
    fetchStoreArticles();
    saveToRecentStores(widget.store.id); // ✅ 변경된 부분
    checkBookmarkStatus();
      updateTodayHits(); // ✅ 이거 꼭 호출하기

  }

  void saveToRecentStores(int storeId) async {
    final prefs = await prefsFuture;
    List<String> recentIds = prefs.getStringList('recentStoreIds') ?? [];

    final idStr = storeId.toString();
    recentIds.remove(idStr); // 중복 제거
    recentIds.insert(0, idStr); // 최신순 정렬
    if (recentIds.length > 5) {
      recentIds = recentIds.sublist(0, 5); // 최대 5개까지만 유지
    }

    await prefs.setStringList('recentStoreIds', recentIds);
    print("✅ 최근 본 가게 ID 목록: $recentIds");
  }

  void fetchMenuData() async {
    try {
      final response = await supabase
          .from('menu_data')
          .select()
          .eq('b_id', widget.store.id)
          .order("id", ascending: true);

      if (response.isEmpty) return;

      setState(() {
        menuList = response.map((item) => menu_data.fromMap(item)).toList();
      });
    } catch (e) {
      print("❌ [에러] 예외 발생: $e");
    }
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  void _callStore(String phoneNumber) async {
    print('[DEBUG] 원본 전화번호: $phoneNumber');
    
    // 전화번호 형식 정제 (캐치테이블 스타일)
    String cleaned = phoneNumber;
    
    // 1. 한글, 특수문자 제거
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 2. 지역번호 처리 (02 -> 02, 나머지 -> 0)
    if (cleaned.startsWith('02')) {
      cleaned = '02' + cleaned.substring(2);
    } else if (cleaned.length >= 10) {
      cleaned = '0' + cleaned;
    }
    
    print('[DEBUG] 정제된 전화번호: $cleaned');
    
    if (cleaned.isEmpty || cleaned.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유효한 전화번호가 없습니다.')),
      );
      return;
    }
    
    final Uri url = Uri(scheme: 'tel', path: cleaned);
    print('[DEBUG] tel url: $url');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전화를 걸 수 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // ✅ 배경 직접 덮을 거라서 transparent
        statusBarIconBrightness: Brightness.dark, // ✅ 검정 아이콘
        statusBarBrightness: Brightness.light, // ✅ iOS용
      ),
      child: Scaffold(
        bottomNavigationBar: StoreBottomBar(
          isBookmarked: isBookmarked,
          onReservePressed: () {
            showReservationBottomSheet(
              context,
              storeName: widget.store.name,
              storeId: widget.store.id,
            );
          },
          onCallPressed: () {
            _callStore(widget.store.number);
          },
          onBookmarkToggle: (newState) async {
            toggleBookmark(); // ✅ 내부에서 상태 변경
          },
        ),

        backgroundColor: Colors.white,
        body: Stack(
          children: [
            NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 200,
                    backgroundColor: Colors.white,
                    scrolledUnderElevation: 0,
                    elevation: 0,
                    leading: Center(
                      // ← Center로 감싸주기!
                      child: Padding(
                        padding: EdgeInsets.only(left: 12), // 적당한 좌측 여백
                        child: _circleIconButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.pop(context, true),
                        ),
                      ),
                    ),

                    actions: [
                      _circleIconButton(
                        icon: Icons.home,
                        onTap: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      _circleIconButton(
                        icon:
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                        onTap: toggleBookmark,
                      ),
                      _circleIconButton(icon: Icons.share, onTap: shareStore),
                      SizedBox(width: 12),
                    ],
                    title:
                        showTitle
                            ? Text(
                              widget.store.name,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            )
                            : null,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ImageViewPage(
                                    imageUrl: widget.store.image,
                                  ),
                            ),
                          );
                        },
                        child: Image.network(
                          widget.store.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: buildStoreHeader()),
                  SliverToBoxAdapter(
                    child: Container(height: 8, color: Colors.grey[200]),
                  ),
                  SliverPersistentHeader(
                    delegate: SliverTabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: Colors.black,
                        indicatorWeight: 2,
                        tabs: [Tab(text: '홈'), Tab(text: '메뉴')],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [buildHomeTab(), buildMenuTab(menuList)],
              ),
            ),

            // ✅ 상태바 영역만 흰색으로 덮기
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).padding.top, // 상태바 높이만큼
                color: Colors.white, // 너가 원하는 흰색
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStoreHeader() {
    // 주소에서 시/군/구만 추출 (예: '강원 춘천시 ...' → '춘천')
    String extractRegion(String address) {
      final parts = address.split(' ');
      if (parts.length >= 2) {
        // 두 번째(시/군/구)만 추출
        return parts[1].replaceAll(RegExp(r'시|군|구'), '');
      }
      return address;
    }
    final region = extractRegion(widget.store.address);
    // 태그 전체 출력
    final tags = widget.store.tags;

    return Padding(
      padding: EdgeInsets.only(right: 16.0, left: 16.0, top: 16.0, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      region,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      Text(' | ', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ...tags.map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.deepOrange,
                          ),
                        ),
                      )),
                    ]
                  ],
                ),
              ),
              linkbutton(),
            ],
          ),
          SizedBox(height: 8),
          Text(
            widget.store.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.star,
                color: Color.fromARGB(255, 238, 200, 49),
                size: 22,
              ),
              SizedBox(width: 2),
              Text(
                "4.7",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.store.description,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          Divider(
            height: 20,
            thickness: 1,
            color: const Color.fromARGB(255, 234, 234, 234),
          ),
          _buildInfoRow(Icons.location_on, widget.store.address),
          _buildInfoRow(Icons.phone, widget.store.number),
          _buildInfoRow(Icons.access_time, widget.store.time),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  InkWell linkbutton() {
    return InkWell(
      onTap: () async {
        final rawUrl = widget.store.url;
        final validUrl = rawUrl.startsWith('http') ? rawUrl : 'https://$rawUrl';
        final Uri uri = Uri.parse(validUrl);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print("❌ URL을 열 수 없습니다: $validUrl");
        }
      },
      child: Icon(
        Icons.public, // 또는 Icons.link
        color: const Color.fromARGB(255, 90, 90, 90),
        size: 24,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // 👈 중앙 정렬
        children: [
          SizedBox(
            height: 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(icon, size: 16, color: Colors.black54),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomeTab() {
    if (storeArticles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text("이 가게에 등록된 아티클이 없습니다."),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: storeArticles.length,
      itemBuilder: (context, index) {
        final article = storeArticles[index];
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        article.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  article.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          article.author,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          article.time,
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMenuTab(List<menu_data> menus) {
  final foodMenus = menus.where((m) => m.category == 1).toList();
  final drinkMenus = menus.where((m) => m.category == 2).toList();
  final orderMenus = menus.where((m) => m.category == 3).toList();

  if (menus.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text('메뉴가 등록되지 않았습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      ),
    );
  }

  return ListView(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    children: [
      if (foodMenus.isNotEmpty) ...[
        Text('🍱 음식', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 15),
        ...foodMenus.map((m) => _buildMenuCard(m)),
        const SizedBox(height: 20),
      ],
      if (drinkMenus.isNotEmpty) ...[
        Text('🥤 음료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 15),
        ...drinkMenus.map((m) => _buildMenuCard(m)),
        const SizedBox(height: 20),
      ],
      if (orderMenus.isNotEmpty) ...[
        Text('🛍️ 주문', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 15),
        ...orderMenus.map((m) => _buildMenuCard(m)),
      ],
    ],
  );
}


  Widget _buildMenuCard(menu_data menu) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: const Color.fromARGB(123, 0, 0, 0),
          barrierDismissible: true,
          builder: (context) => MenuDetailModal(menu: menu),
        );
      },
      child: Column(
        children: [
          Container(
            color: Colors.white,
            // padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 (왼쪽)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    menu.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // 텍스트 (가운데)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        menu.description,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                // 가격 (오른쪽)
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    '${menu.price}원',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8, top: 8),
            child: Container(
              height: 1,
              color: const Color.fromARGB(255, 223, 223, 223),
            ),
          ),
        ],
      ),
    );
  }
}
