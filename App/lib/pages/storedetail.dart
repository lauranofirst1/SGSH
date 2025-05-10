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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Icon(icon, size: 22, color: Color(0xFF2D3436)),
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xFFF7F7F7),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.store.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                _buildActionButton(
                  icon: Icons.share,
                  onTap: () => _showSnackbar('공유하기'),
                ),
                _buildActionButton(
                  icon: Icons.favorite_border,
                  onTap: () => _showSnackbar('찜하기'),
                ),
                SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.store.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text(
                                '4.5',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(리뷰 128)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      widget.store.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 28),
                    _buildInfoSection(
                      title: '영업시간',
                      content: '매일 11:00 - 22:00',
                      icon: Icons.access_time,
                    ),
                    _buildInfoSection(
                      title: '주소',
                      content: '서울시 강남구 테헤란로 123',
                      icon: Icons.location_on,
                    ),
                    _buildInfoSection(
                      title: '전화번호',
                      content: '02-123-4567',
                      icon: Icons.phone,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showReservationBottomSheet(
                      context,
                      storeName: widget.store.name,
                      storeId: widget.store.id,
                    );
                  },
                  child: Text('예약하기'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: widget.store.number,
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      _showSnackbar('전화를 연결할 수 없습니다.');
                    }
                  },
                  child: Text('전화하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D3436),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
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
    if (menus.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            '메뉴가 등록되지 않았습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: menus.length,
      shrinkWrap: true, // ✅ 자식들 크기만큼만 렌더링
      physics: NeverScrollableScrollPhysics(), // ✅ NestedScrollView와의 스크롤 충돌 방지
      separatorBuilder: (_, __) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildMenuCard(menus[index]);
      },
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
            decoration: BoxDecoration(color: Colors.white),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 텍스트 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                      SizedBox(height: 8),
                      Text(
                        '${menu.price}원',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12),

                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          menu.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
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
