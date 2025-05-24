import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/widgets/search_bar.dart' as custom; // 커스텀 SearchBar
import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';
import 'package:app/models/article.dart';
import 'package:app/pages/articlepage.dart'; // 클릭 시 상세 페이지 이동

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
  List<article_data> magazineArticles = [];

  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    fetchStores();
    fetchMagazineArticles(); // ← 추가

    loadRecentStores();
  }

  void fetchMagazineArticles() async {
    try {
      final response = await supabase
          .from('article_data')
          .select()
          .eq('type', 4); // 타입 4만 가져오기

      setState(() {
        magazineArticles = response.map((e) => article_data.fromMap(e)).toList();
        // 랜덤으로 섞기
        magazineArticles.shuffle();
      });
    } catch (e) {
      print('❌ 매거진 로딩 실패: $e');
    }
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
        filteredList = List.from(storeList);
      } else {
        hasSearched = true;
        // 검색어에서 '#' 제거
        final cleanQuery = query.replaceAll('#', '').toLowerCase();
        
        filteredList = storeList.where((store) {
          final name = store.name.toLowerCase();
          final address = store.address.toLowerCase();
          final description = store.description.toLowerCase();
          final tags = store.tags.join(' ').toLowerCase();
          
          return name.contains(cleanQuery) ||
              address.contains(cleanQuery) ||
              description.contains(cleanQuery) ||
              tags.contains(cleanQuery);
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
      appBar: AppBar(
                  automaticallyImplyLeading: false, // <-- 이 줄을 추가
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '검색하기',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
            letterSpacing: -1.1,
          ),
        ),
        foregroundColor: Colors.black, // 버튼색이 스크롤에 의해 바뀌지 않도록
        surfaceTintColor: Colors.white, // 머티리얼 3 대응용 (앱바 배경 흐림 방지)
        shadowColor: Colors.transparent, // 그림자 투명화(선택)
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 바깥 터치 시 키보드 닫기
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // 스크롤 시 키보드 닫기
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: custom.SearchBar(
                  controller: _searchController,
                  onSubmitted: (value) {
                    filterStores(value);
                    FocusScope.of(context).unfocus(); // 완료 누르면 키보드 닫기
                  },
                  onChanged: filterStores,
                ),
              ),

              if (!hasSearched) ...[
                // ✅ 추천 해시태그는 항상 표시
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '추천 해시태그',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
                  child: Row(
                    children:
                       [
  '#전문점',
  '#막국수',
  '#전통',
  '#춘천',
  '#닭갈비',
  '#숯불',
  '#메밀',
  '#맛집',
  '#아름다운',
].map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            _searchController.text = tag;
                            filterStores(tag);
                            FocusScope.of(context).unfocus();
                          },
                          child: Chip(
                            label: Text(
                              tag,
                              style: TextStyle(
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Color(0xFFE0E0E0)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 2,
                            shadowColor: Colors.black12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // ✅ 매거진 아티클이 있으면 먼저 보여주기
                if (magazineArticles.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 12, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '추천 매거진',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: magazineArticles.length,
                      separatorBuilder: (_, __) => SizedBox(width: 18),
                      itemBuilder: (context, index) {
                        final article = magazineArticles[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticlePage(article: article),
                              ),
                            );
                          },
                          child: Container(
                            width: 210,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              image: DecorationImage(
                                image: NetworkImage(article.image ?? ''),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.desc,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(blurRadius: 8, color: Colors.black),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  article.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    shadows: [
                                      Shadow(blurRadius: 8, color: Colors.black),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],

              if (hasSearched)
                filteredList.isEmpty
                  ? Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final store = filteredList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 12,
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
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // 키보드 올라올 때 하단 여백
            ],
          ),
        ),
      ),
    );
  }
}
