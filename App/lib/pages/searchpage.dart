import 'package:app/widgets/store_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final supabase = Supabase.instance.client;
  List<business_data> storeList = [];
  List<business_data> filteredList = [];
  List<String> recentStores = [];

  final List<String> popularSearches = [
    "스시카이키",
    "아르모니움",
    "아오이바라",
    "고청담 용산점",
    "키츠 스키야키",
    "블루메쯔 광화문점",
    "도톤보리서울",
    "드포레 와인다이닝 용산",
    "야키토리 슈츠",
    "종문",
  ];

  @override
  void initState() {
    super.initState();
    fetchStores();
    loadRecentStores();
  }

  void fetchStores() async {
    try {
      var response = await supabase
          .from("business_data")
          .select()
          .order("id", ascending: true);
      setState(() {
        storeList =
            response
                .map<business_data>((data) => business_data.fromMap(data))
                .toList();
        filteredList = List.from(storeList);
      });
    } catch (e) {
      print("❌ 오류 발생: $e");
    }
  }

  void filterStores(String query) {
    setState(() {
      filteredList =
          storeList.where((store) {
            return store.name.toLowerCase().contains(query.toLowerCase()) ||
                store.address.toLowerCase().contains(query.toLowerCase());
          }).toList();
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
        title: Text(
          '가게 검색',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: filterStores,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                hintText: '검색어를 입력하세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          if (_searchController.text.isEmpty) ...[
            if (recentStores.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '최근 본 가게',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Container(
                height: 40,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      recentStores
                          .map(
                            (storeName) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: ActionChip(
                                backgroundColor: Colors.white,

                                label: Text(storeName),
                                onPressed: () {
                                  final selectedStore = storeList.firstWhere(
                                    (store) => store.name == storeName,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => StoreDetailPage(
                                            store: selectedStore,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '실시간 인기 검색어',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: popularSearches.length,
                itemBuilder:
                    (context, index) => ListTile(
                      leading: Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text(popularSearches[index]),
                      onTap: () {
                        _searchController.text = popularSearches[index];
                        filterStores(popularSearches[index]);
                      },
                    ),
              ),
            ),
          ] else
            Expanded(
              child:
                  filteredList.isEmpty
                      ? Center(child: Text("검색 결과가 없습니다."))
                      : ListView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: StoreCard(
                              store: filteredList[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => StoreDetailPage(
                                          store: filteredList[index],
                                        ),
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
}
