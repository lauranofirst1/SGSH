import 'package:app/models/article.dart';
import 'package:app/models/business.dart';
import 'package:app/pages/articlepage.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/pages/storelist.dart';
import 'package:app/widgets/diningmagazinesection.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Mainpage extends StatefulWidget {
  @override
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final List<Map<String, dynamic>> items = [
    {'emoji': '🍚', 'label': "한식"},
    {'emoji': '🍜', 'label': "중식"},
    {'emoji': '🍣', 'label': "일식"},
    {'emoji': '☕', 'label': "카페"},
    {'emoji': '🍗', 'label': "치킨"},
    {'emoji': '🍔', 'label': "버거"},
  ];

  // List<article_data> article = [];
  List<article_data> bannerArticles = [];
  List<article_data> newsArticles = [];
  List<article_data> magazineArticles = [];

  final supabase = Supabase.instance.client;
  late Future<SharedPreferences> prefsFuture;

  @override
  void initState() {
    super.initState();
    prefsFuture = SharedPreferences.getInstance();
    fetchStores();
    prefsFuture.then((prefs) {
      setState(() {});
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '가치가게',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        foregroundColor: Colors.black, // 버튼색이 스크롤에 의해 바뀌지 않도록
        surfaceTintColor: Colors.white, // 머티리얼 3 대응용 (앱바 배경 흐림 방지)
        shadowColor: Colors.transparent, // 그림자 투명화(선택)
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Article(article: bannerArticles),
            Padding(
              padding: EdgeInsets.all(8).copyWith(top: 20),
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 8,
                runSpacing: 12,
                children:
                    items.map((item) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 6 - 12,
                        child: _buildEmojiText(
                          item['emoji'],
                          item['label'],
                          context,
                        ),
                      );
                    }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '최근 본 항목',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),

            buildRecentItems(),
            const SizedBox(height: 20),
            DummyArticleList(newsArticles: newsArticles),
            DiningMagazineSection(magazineArticles: magazineArticles),
          ],
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

        List<String> recentStores =
            snapshot.data!.getStringList('recentStores') ?? [];

        return FutureBuilder<List<business_data>>(
          future: Future.wait(
            recentStores.map((storeName) async {
              var response =
                  await supabase
                      .from('business_data')
                      .select()
                      .eq('name', storeName)
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

            return Container(
              height: 150,
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
                          builder: (context) => StoreDetailPage(store: store),
                        ),
                      );
                    },
                    child: Container(
                      width: 160,
                      margin: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              store.image,
                              height: 90,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    height: 90,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.store,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              store.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'SF Pro Display',
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmojiText(String emoji, String label, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoreListPage()),
        ).then((_) {
          setState(() {
            prefsFuture = SharedPreferences.getInstance();
          });
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(emoji, style: TextStyle(fontSize: 28)),
          SizedBox(height: 4),
          Text(label),
        ],
      ),
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
          padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Text(
            '가치가게 소식',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
