import 'package:app/data/dummy_menudetail.dart';
import 'package:app/pages/imageviewpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/business.dart';
import 'package:app/models/menu.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreDetailPage extends StatefulWidget {
  final business_data store;

  StoreDetailPage({required this.store});

  @override
  _StoreDetailPageState createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage>
    with SingleTickerProviderStateMixin {
  List<menu_data> menuList = [];
  late Future<SharedPreferences> prefsFuture;
  final supabase = Supabase.instance.client;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    prefsFuture = SharedPreferences.getInstance();
    fetchMenuData();
    saveToRecentStores(widget.store.name);

    _tabController = TabController(length: 5, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            widget.store.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5, // 약간의 그림자
          iconTheme: IconThemeData(color: Colors.black),
        ),

        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: buildStoreHeader()), // 상단 가게 정보 전체
              SliverPersistentHeader(
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,

                    indicatorColor: Colors.black,
                    indicatorWeight: 2,

                    tabs: [
                      Tab(text: '홈'),
                      Tab(text: '소식'),
                      Tab(text: '메뉴'),
                      Tab(text: '사진'),
                      Tab(text: '리뷰'),
                    ],
                  ),
                ),
                pinned: true, // 탭바 고정
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              buildHomeTab(),
              buildInfoTab(),
              buildMenuTab(menuList),
              buildPhotoTab(),
              buildReviewTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReviewTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children:
          reviewDummyData.map((review) {
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(child: Text(review['avatar'])),
                  title: Text(
                    review['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(review['content']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < review['rating']
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Divider(),
              ],
            );
          }).toList(),
    );
  }

  Widget buildPhotoTab() {
    return GridView.count(
      padding: EdgeInsets.all(16),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children:
          photoDummyData.map((photoUrl) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    ),
              ),
            );
          }).toList(),
    );
  }

  Widget buildInfoTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children:
          infoDummyData.map((info) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    info['content'] ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text(
                    info['date'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget buildStoreHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ImageViewPage(
                      imageUrl: widget.store.image,
                      // ✅ 고유한 tag 넘기기
                    ),
              ),
            );
          },

          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                        color: Colors.grey[600],
                      ),
                    ),
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 줄바꿈 시 위쪽 정렬
                children: [
                  Text(
                    widget.store.description,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  linkbutton(),
                ],
              ),

              Divider(height: 20, thickness: 1),
              _buildInfoRow('주소:', widget.store.address),
              _buildInfoRow('전화:', widget.store.number),
              _buildInfoRow('영업시간:', widget.store.time),
              _buildInfoRow('위도:', widget.store.lat),
              _buildInfoRow('경도:', widget.store.lng),

              SizedBox(height: 8),
            ],
          ),
        ),
      ],
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

  Widget buildHomeTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎉 오늘의 프로모션
          Text(
            '🎉 오늘의 프로모션',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.tag_fill,
                  color: CupertinoColors.systemRed,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '런치타임 모든 메뉴 15% 할인!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '평일 오전 11시 - 오후 2시',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✨ 대표 인기 메뉴
          Text(
            '✨ 대표 인기 메뉴',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child:
                  // Image.network(
                  //   'https://source.unsplash.com/featured/?restaurant-food',
                  //   fit: BoxFit.cover,
                  //   width: double.infinity,
                  //   height: 160,
                  // ),
                  Container(width: double.infinity, height: 160),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '크림 파스타 🍝',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '고소한 크림소스와 신선한 재료로 만든 인기 메뉴',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // 👍 고객 리뷰
          Text(
            '👍 고객 리뷰',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      CupertinoIcons.star_fill,
                      color: CupertinoColors.systemYellow,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '음식이 너무 맛있고, 서비스가 훌륭해요! 자주 방문하고 싶은 곳입니다.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  '- 서울맛집러버',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // label 너비 고정 → 정렬 예쁘게
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                height: 1.4, // 줄 간격 넉넉하게
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuTab(List<menu_data> menus) {
    return GridView.count(
      padding: EdgeInsets.all(20),

      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // 외부 스크롤 사용 시 필요
      children: menus.map((menu) => _buildMenuCard(menu)).toList(),
    );
  }

  Widget _buildMenuCard(menu_data menu) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5), // 반투명 회색 배경
          barrierDismissible: true,
          builder: (context) => MenuDetailModal(menu: menu),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                menu.image,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 100,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, color: Colors.grey[600]),
                    ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.name,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${menu.price}원',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePopup(String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class MenuDetailModal extends StatelessWidget {
  final menu_data menu;

  const MenuDetailModal({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        padding: EdgeInsets.all(20),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(20),
        // ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 내용만큼만 높이
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  menu.image,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              Text(
                menu.name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '${menu.price}원',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              SizedBox(height: 16),
              Text(
                menu.description,
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('닫기', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
