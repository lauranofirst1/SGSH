import 'dart:ffi';

import 'package:app/data/dummy_menudetail.dart';
import 'package:app/pages/imageviewpage.dart';
import 'package:app/widgets/menudetail_modal.dart';
import 'package:flutter/cupertino.dart';
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
  bool isBookmarked = false;

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

  @override
  void initState() {
    super.initState();
    prefsFuture = SharedPreferences.getInstance();
    fetchMenuData();
    saveToRecentStores(widget.store.name);

    _tabController = TabController(length: 5, vsync: this);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
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
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
                Navigator.popUntil(context, (route) => route.isFirst); // 홈으로
              },
            ),
            _circleIconButton(
              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              onTap: toggleBookmark,
            ),
            _circleIconButton(icon: Icons.share, onTap: shareStore),
            SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.white,
            ),

            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(child: buildStoreHeader()),

                    // ✅ 회색 여백 추가
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
                          tabs: [
                            Tab(text: '홈'),
                            Tab(text: '소식'),
                            Tab(text: '메뉴'),
                            Tab(text: '사진'),
                            Tab(text: '리뷰'),
                          ],
                        ),
                      ),
                      pinned: true,
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
          ],
        ),
      ),
    );

    // 나머지 위젯 함수들은 생략. buildStoreHeader, buildHomeTab, buildInfoTab 등등
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 줄바꿈 시 위쪽 정렬
                children: [
                  Text(
                    widget.store.description,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
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

  Widget _buildInfoRow(IconData icon, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.0),
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
        SizedBox(width: 12),
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
}




 // void _showImagePopup(String imageUrl) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => Dialog(
  //           backgroundColor: Colors.transparent,
  //           child: Stack(
  //             children: [
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(12),
  //                 child: Image.network(imageUrl, fit: BoxFit.contain),
  //               ),
  //               Positioned(
  //                 top: 10,
  //                 right: 10,
  //                 child: IconButton(
  //                   icon: Icon(Icons.close, color: Colors.white, size: 30),
  //                   onPressed: () => Navigator.pop(context),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //   );}

