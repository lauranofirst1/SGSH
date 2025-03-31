import 'package:app/models/article.dart';
import 'package:app/models/business.dart';
import 'package:app/pages/articlepage.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/pages/storelist.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Mainpage extends StatefulWidget {
  @override
  _MainpageState createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  final List<Map<String, dynamic>> items = [
    {'icon': Icons.cake, 'label': "케이크"},
    {'icon': Icons.local_pizza, 'label': "피자"},
    {'icon': Icons.coffee, 'label': "커피"},
    {'icon': Icons.restaurant, 'label': "저녁식사"},
    {'icon': Icons.local_bar, 'label': "바"},
    {'icon': Icons.fastfood, 'label': "패스트"},
    {'icon': Icons.local_florist, 'label': "플로리"},
    {'icon': Icons.store_mall_directory, 'label': "쇼핑"},
    {'icon': Icons.local_movies, 'label': "영화"},
    {'icon': Icons.local_drink, 'label': "음료"},
    {'icon': Icons.local_offer, 'label': "특가"},
    {'icon': Icons.local_grocery_store, 'label': "마켓"},
  ];

  List<article_data> article = []; // 📌 Store 객체 리스트
  final supabase = Supabase.instance.client;
  late Future<SharedPreferences> prefsFuture;

  @override
  void initState() {
    super.initState();
    prefsFuture = SharedPreferences.getInstance();
    fetchStores();

    // ✅ 초기화 즉시 UI 갱신을 위한 코드 추가
    prefsFuture.then((prefs) {
      setState(() {});
    });
  }

  // 📌 Supabase에서 가게 데이터 가져오기
  void fetchStores() async {
    try {
      var response = await supabase.from("article_data").select();
      setState(() {
        article =
            response
                .map<article_data>((data) => article_data.fromMap(data))
                .toList(); // 🔥 변환 적용
      });
    } catch (e) {
      print("❌ 오류 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '메인페이지',
          style: TextStyle(color: Colors.black, fontFamily: 'Helvetica'),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Article(article: article),
            Padding(
              padding: EdgeInsets.all(10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // 한 행에 6개의 아이템
                  childAspectRatio: 1, // 아이템 비율 1:1
                  crossAxisSpacing: 1, // 가로 간격
                  mainAxisSpacing: 1, // 세로 간격
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildIconText(
                    items[index]['icon'],
                    items[index]['label'],
                    context,
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(vertical: 12.0),
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "최근 본 상품",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  Text(
                    "더 보기",
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ),
            buildRecentItems(),
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

        if (recentStores.isEmpty) {
          return Center(child: Text("최근 본 가게가 없습니다."));
        }

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
                          
   // ✅ 고유한 태그로 설정
 ClipRRect(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(16),
    ),
    child: Image.network(
      store.image,
      height: 90,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
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

  Widget _buildIconText(IconData icon, String label, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StoreListPage()),
        ).then((_) {
          // ✅ 여기서 다시 prefsFuture를 갱신해줍니다.
          setState(() {
            prefsFuture = SharedPreferences.getInstance();
          });
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 24),
          SizedBox(height: 2),
          Text(label),
        ],
      ),
    );
  }
}

//===============Article===============
class Article extends StatelessWidget {
  const Article({super.key, required this.article});

  final List<article_data> article;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 160, 160, 160),
        borderRadius: BorderRadius.circular(10),
      ),
      child: PageView(
        children:
            article
                .map(
                  (article) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Articlepage(article: article),
                        ),
                      );
                    },
                    child: Center(
                      child: Text(
                        article.title, // 제목을 표시
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
