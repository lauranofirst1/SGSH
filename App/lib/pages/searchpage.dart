import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/widgets/search_bar.dart' as custom; // 커스텀 SearchBar
import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<business_data> storeList = [];
  List<business_data> filteredList = [];
  List<String> recentStores = [];
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    fetchStores();
    loadRecentStores();
  }

  void fetchStores() async {
    try {
      final response = await supabase
          .from("business_data")
          .select()
          .order("id");
      setState(() {
        storeList =
            response
                .map<business_data>((data) => business_data.fromMap(data))
                .toList();
        filteredList = List.from(storeList);
      });
    } catch (e) {
      print("❌ Supabase 오류: $e");
    }
  }

  void filterStores(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        hasSearched = false;
        filteredList = List.from(storeList); // 또는 []
      } else {
        hasSearched = true;
        filteredList =
            storeList.where((store) {
              final name = store.name.toLowerCase();
              final address = store.address.toLowerCase();
              return name.contains(query.toLowerCase()) ||
                  address.contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  void loadRecentStores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentStores = prefs.getStringList('recentStores') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '검색하기',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: custom.SearchBar(
              controller: _searchController,
              onSubmitted: (value) {
                filterStores(value);
                FocusScope.of(context).unfocus();
              },
              onChanged: filterStores, // 🔥 추가!
            ),
          ),

          if (!hasSearched) ...[
       
             Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '추천 해시태그',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  padding: EdgeInsets.symmetric(horizontal: 12.0),
  child: Row(
    children: [
      '#학생단골',
      '#춘천맛집',
      '#스시오마카세',
      '#강원도맛집',
      '#감자',
    ].map((tag) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () {
            _searchController.text = tag; // 입력창에 텍스트 반영
            filterStores(tag); // 검색 실행
            FocusScope.of(context).unfocus(); // 키보드 닫기
          },
          child: Chip(
            label: Text(
              tag,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
        ),
      );
    }).toList(),
  ),
),




            const SizedBox(height: 12),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '어떤 매장을 찾으세요?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: ListView(
                padding: EdgeInsets.only(left: 15),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildPromoCard('룸이 있는', '#조용한 #프라이빗한'),
                  _buildPromoCard('전국 맛집 라인업 공개!', '#핫플 #유명맛집'),
                ],
              ),
            ),

            const SizedBox(height: 16),

           
          ],

          if (hasSearched)
            Expanded(
              child:
                  filteredList.isEmpty
                      ? const Center(child: Text('검색 결과가 없습니다.'))
                      : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final store = filteredList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6,
                            ),
                            child: StoreCard(
                              store: store,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => StoreDetailPage(store: store),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String title, String subtitle) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/dummy_image/sushi.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black.withOpacity(0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
