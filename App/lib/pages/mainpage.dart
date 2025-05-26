import 'package:app/models/article.dart';
import 'package:app/models/business.dart';
import 'package:app/pages/articlepage.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/pages/storelist.dart';
import 'package:app/services/supabase_service.dart';
import 'package:app/widgets/diningmagazinesection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:app/models/menu.dart';

class Mainpage extends StatefulWidget {
  @override
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🥘', 'label': "한식", 'category': 1},
    {'emoji': '🍜', 'label': "중식", 'category': 2},
    {'emoji': '🍱', 'label': "일식", 'category': 3},
    {'emoji': '🍔', 'label': "양식", 'category': 4},
    {'emoji': '☕️', 'label': "카페", 'category': 5},
    {'emoji': '🍽️', 'label': "기타", 'category': 6},
  ];

  // List<article_data> article = [];
  List<article_data> bannerArticles = [];
  List<article_data> newsArticles = [];
  List<article_data> magazineArticles = [];

  final supabase = Supabase.instance.client;
  late Future<SharedPreferences> prefsFuture;

  List<business_data> recommendedStores = [];
  String userName = '';
  List<menu_data> menuList = [];

  @override
  void initState() {
    super.initState();
    prefsFuture = SharedPreferences.getInstance();
    fetchStores();
    fetchMenuList();

    SupabaseService().getUserProfile().then((profile) {
      final email = profile?.email;
      final namePart = email?.split('@')[0];
      setState(() {
        userName = namePart!;
      });
    });

    fetchTopViewedStores().then((stores) {
      setState(() {
        recommendedStores = stores;
      });
      // 디버깅: 추천 매장 카테고리명 출력
      for (var store in stores) {
        print('가게명: \\${store.name}, 카테고리: \\${store.category}');
      }
    });
  }

  Future<List<business_data>> fetchTopViewedStores() async {
  try {
    final today = DateTime.now();
    final weekAgo = today.subtract(Duration(days: 7));
    final weekAgoStr =
        '${weekAgo.year}-${weekAgo.month.toString().padLeft(2, '0')}-${weekAgo.day.toString().padLeft(2, '0')}';

    print("🕒 조회 기준: $weekAgoStr 이후 데이터");

    // 1. 최근 7일 조회수 합산
    final response = await supabase
        .from('business_hits')
        .select('b_id, hits')
        .gte('date', weekAgoStr);

    print("📊 조회된 hits rows: ${response.length}");
    for (var item in response) {
      print("→ b_id: ${item['b_id']}, hits: ${item['hits']}");
    }

    // 2. [b_id별 합산]
    final Map<int, int> hitsByStore = {};
    for (var item in response) {
      final bId = item['b_id'] as int;
      final hits = item['hits'] as int;
      hitsByStore[bId] = (hitsByStore[bId] ?? 0) + hits;
    }

    print("📈 합산된 조회수:");
    hitsByStore.forEach((id, hits) {
      print("→ 매장 $id: $hits회");
    });

    // 3. 정렬: 조회수 많은 순 + 같은 조회수는 랜덤 섞기
    final sortedIds =
        hitsByStore.entries.toList()
          ..shuffle()
          ..sort((a, b) => b.value.compareTo(a.value));

    final topIds = sortedIds.take(7).map((e) => e.key).toList();
    print("🏆 추천 매장 ID(정렬된): $topIds");

    // 4. 상위 매장 정보 가져오기
    final storesResponse = await supabase
        .from('business_data')
        .select()
        .inFilter('id', topIds);

    print("🏪 매장 정보 수신 완료: ${storesResponse.length}");

    List<business_data> topStores =
        storesResponse
            .map<business_data>((data) => business_data.fromMap(data))
            .toList();

    // 5. 순서 정렬
    topStores.sort(
      (a, b) => topIds.indexOf(a.id!).compareTo(topIds.indexOf(b.id!)),
    );

    print("✅ 최종 추천 매장 리스트:");
    for (var store in topStores) {
      print("→ ${store.name} (${store.id})");
    }

    return topStores;
  } catch (e) {
    print("❌ 추천 매장 조회 실패: $e");
    return [];
  }
}


  void fetchStores() async {
    try {
      var response = await supabase.from("article_data").select();
      List<article_data> allArticles =
          response
              .map<article_data>((data) => article_data.fromMap(data))
              .toList();

      setState(() {
        bannerArticles = allArticles.where((a) => a.type == 2).toList();
        newsArticles = allArticles.where((a) => a.type == 3).toList();
        magazineArticles = allArticles.where((a) => a.type == 4).toList();

        print(response.map((e) => e['type']).toList());
      });
    } catch (e) {
      print("❌ 오류 발생: $e");
    }
  }

  void fetchMenuList() async {
    try {
      var response = await supabase
          .from("menu_data")
          .select()
          .order("id", ascending: true);
      setState(() {
        menuList = response.map<menu_data>((data) => menu_data.fromMap(data)).toList();
      });
    } catch (e) {
      print("❌ 메뉴 데이터 불러오기 실패: $e");
    }
  }

  // Future<List<business_data>> fetchRandomStores() async {
  //   try {
  //     final response = await supabase.from('business_data').select();

  //     List<business_data> allStores =
  //         response
  //             .map<business_data>((data) => business_data.fromMap(data))
  //             .toList();

  //     allStores.shuffle(); // ✅ 클라이언트에서 무작위 섞기

  //     return allStores.take(5).toList(); // ✅ 상위 5개만
  //   } catch (e) {
  //     print("❌ 랜덤 매장 불러오기 실패: $e");
  //     return [];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Text(
              '가치가게',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'BETA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          fetchStores();
          final stores = await fetchTopViewedStores();
          setState(() {
            recommendedStores = stores;
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Article(article: bannerArticles),
              Padding(
                padding: EdgeInsets.all(16).copyWith(top: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '카테고리',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: items.map((item) {
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                 onTap: () {
  print("👉 선택된 카테고리: ${item['category']} (${item['category'].runtimeType})");

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StoreListPage(
        category: item['category'].toString(), // category: '1' 등으로 전달
      ),
    ),
  );
},

                                  child: Column(
                                    children: [
                                      Text(
                                        item['emoji'],
                                        style: const TextStyle(
                                          fontFamily: 'TossFace',
                                          fontSize: 36,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        item['label'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              buildRecentItems(),
              RecommendedStoreSection(
                userName: userName.isNotEmpty ? userName : '회원',
                stores: recommendedStores,
              ),
             
            
              PriceTabMenuList(menus: menuList, stores: recommendedStores),
              DiningMagazineSection(magazineArticles: magazineArticles),
              SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecentItems() {
    return FutureBuilder<SharedPreferences>(
      future: prefsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(child: Text("최근 본 가게가 없습니다."));
        }

        List<String> recentIds =
            snapshot.data!.getStringList('recentStoreIds') ?? [];

        if (recentIds.isEmpty) {
          return Center(child: Text("최근 본 가게가 없습니다."));
        }

        return FutureBuilder<List<business_data>>(
          future: Future.wait(
            recentIds.map((id) async {
              final response =
                  await supabase
                      .from('business_data')
                      .select()
                      .eq('id', int.parse(id))
                      .single();
              return business_data.fromMap(response);
            }),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.hasError) {
              return Center(child: Text("최근 본 가게 정보를 불러오지 못했습니다."));
            }

            final stores = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                  child: Text(
                    '최근 본 매장',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    '최근 본 매장을 모아봤어요',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
                Container(
                  height: 190,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      final store = stores[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StoreDetailPage(store: store),
                            ),
                          );
                          if (result == true) setState(() {}); // 돌아올 때 새로고침
                        },
                        child: Container(
                          width: 180,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 16 : 10,
                            right: 10,
                          ),
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                                child: Image.network(
                                  store.image,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        height: 120,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image),
                                      ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            store.description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Article extends StatelessWidget {
  const Article({super.key, required this.article});

  final List<article_data> article;

  @override
  Widget build(BuildContext context) {
    if (article.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "게시물이 없습니다.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
      ),
      items:
          article.map((article) {
            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticlePage(article: article),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 배경 이미지
                        Image.network(
                          article.image ?? '',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image, size: 40),
                              ),
                        ),

                        // 반투명 오버레이 + 텍스트
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                article.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                article.desc ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
    );
  }
}

class DummyArticleList extends StatelessWidget {
  final List<article_data> newsArticles;

  const DummyArticleList({super.key, required this.newsArticles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Text(
            '가치가게 소식',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
          child: Text(
            '가치가게 소식을 모아봤어요',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        ...newsArticles.map((article) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.image ?? '',
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 32),
                    ),
              ),
            ),
            title: Text(
              article.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(article.desc ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(article: article),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }
}

class RecommendedStoreSection extends StatelessWidget {
  final String userName;
  final List<business_data> stores;

  const RecommendedStoreSection({
    super.key,
    required this.userName,
    required this.stores,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Text(
            '$userName님이 좋아할 매장',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            '마음에 들 만한 곳을 모아봤어요',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
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
                  width: 180,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 10,
                    right: 10,
                  ),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: Image.network(
                          store.image,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 120,
                                color: Colors.grey[300],
                                child: Icon(Icons.image),
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    store.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PriceTabMenuList extends StatefulWidget {
  final List<menu_data> menus; // 메뉴 리스트
  final List<business_data> stores; // 가게 리스트

  const PriceTabMenuList({super.key, required this.menus, required this.stores});

  @override
  State<PriceTabMenuList> createState() => _PriceTabMenuListState();
}

class _PriceTabMenuListState extends State<PriceTabMenuList> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> priceTabs = ['1만원 이하', '3만원 이하', '그 이상'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: priceTabs.length, vsync: this);
  }

  List<menu_data> getMenusByPrice(int tabIndex) {
    List<menu_data> filtered;
    switch (tabIndex) {
      case 0:
        filtered = widget.menus.where((m) => m.price <= 10000).toList();
        break;
      case 1:
        filtered = widget.menus.where((m) => m.price > 10000 && m.price <= 30000).toList();
        break;
      case 2:
        filtered = widget.menus.where((m) => m.price > 30000).toList();
        break;
      default:
        filtered = widget.menus;
    }
    filtered.shuffle();
    return filtered.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 4),
          child: Text(
            '가격대별 BEST',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
          child: Text(
            '가격대별 인기 메뉴를 모아봤어요',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: priceTabs.map((t) => Tab(text: t)).toList(),
        ),
        SizedBox(
          height: 440, // 5개 메뉴가 스크롤 없이 들어갈 수 있도록 높이 조정 (overflow 방지)
          child: TabBarView(
            controller: _tabController,
            children: List.generate(priceTabs.length, (index) {
              final menus = getMenusByPrice(index);
              if (menus.isEmpty) {
                return Center(child: Text('해당 가격대의 메뉴가 없습니다.'));
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(menus.length > 5 ? 5 : menus.length, (i) {
                  final menu = menus[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoreDetailPage(store: widget.stores.firstWhere((s) => s.id == menu.b_id, orElse: () => business_data(
                            id: menu.b_id,
                            name: menu.name,
                            address: '',
                            time: '',
                            number: '',
                            description: '',
                            image: menu.image,
                            url: '',
                            lat: '0.0',
                            lng: '0.0',
                            tags: [],
                            category: 6,
                          ))),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              menu.image,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 52,
                                height: 52,
                                color: Colors.grey[200],
                                child: Icon(Icons.image, color: Colors.grey, size: 24),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menu.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 3),
                                Text(
                                  menu.description,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${menu.price.toString()}원',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }
}


