import 'package:app/data/dummy_article.dart';
import 'package:app/pages/imageviewpage.dart';
import 'package:app/widgets/menudetail_modal.dart';
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
  late Future<SharedPreferences> prefsFuture;
  final supabase = Supabase.instance.client;
  late TabController _tabController;
  bool isBookmarked = false;
  bool showTitle = false;

  void toggleBookmark() {
    setState(() {
      isBookmarked = !isBookmarked;
    });

    print(
      isBookmarked
          ? "🔖 북마크 추가됨: ${widget.store.name}"
          : "❌ 북마크 해제됨: ${widget.store.name}",
    );
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
    _scrollController.addListener(() {
      if (_scrollController.offset > 150 && !showTitle) {
        setState(() => showTitle = true);
      } else if (_scrollController.offset <= 150 && showTitle) {
        setState(() => showTitle = false);
      }
    });

    _tabController = TabController(length: 2, vsync: this);
    prefsFuture = SharedPreferences.getInstance();
    fetchMenuData();
    saveToRecentStores(widget.store.name);
  }

  void saveToRecentStores(String storeName) async {
    final prefs = await prefsFuture;
    List<String> recentStores = prefs.getStringList('recentStores') ?? [];
    recentStores.remove(storeName);
    recentStores.insert(0, storeName);
    if (recentStores.length > 5) {
      recentStores = recentStores.sublist(0, 5);
    }
    await prefs.setStringList('recentStores', recentStores);
    print("✅ 최근 본 가게 업데이트 완료: $recentStores");
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

 @override
Widget build(BuildContext context) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // ✅ 배경 직접 덮을 거라서 transparent
      statusBarIconBrightness: Brightness.dark, // ✅ 검정 아이콘
      statusBarBrightness: Brightness.light, // ✅ iOS용
    ),
    child: Scaffold(
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
                  leading: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: _circleIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    _circleIconButton(
                      icon: Icons.home,
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                    _circleIconButton(
                      icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      onTap: toggleBookmark,
                    ),
                    _circleIconButton(icon: Icons.share, onTap: shareStore),
                    SizedBox(width: 12),
                  ],
                  title: showTitle
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
                            builder: (_) => ImageViewPage(imageUrl: widget.store.image),
                          ),
                        );
                      },
                      child: Image.network(
                        widget.store.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported, size: 50),
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
    return Padding(
      padding: EdgeInsets.only(right: 16.0,left: 16.0, top: 16.0,bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '춘천 | 파스타',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'pretendard',
                  fontWeight: FontWeight.w100,
                ),
              ),
              linkbutton(),
            ],
          ),
          Text(
            widget.store.name,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 25,
              fontWeight: FontWeight.w700,
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
                  fontFamily: 'pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            widget.store.description,
            style: TextStyle(
              fontFamily: 'Pretendard',
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
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: dummyArticles.length,
      itemBuilder: (context, index) {
        final article = dummyArticles[index];
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
                /// 🔔 Title with icon
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

                /// 📝 Content
                Text(
                  article.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 16),

                /// 🧑‍💼 Author & 🕒 Time
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
