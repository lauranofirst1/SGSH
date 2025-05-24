import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';
import 'package:app/models/business.dart'; // 📌 Store 모델 가져오기
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 📍 가게 리스트 페이지
class StoreListPage extends StatefulWidget {
  final String category;
  
  const StoreListPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  _StoreListPageState createState() => _StoreListPageState();
}

class _StoreListPageState extends State<StoreListPage> {
  List<business_data> storeList = []; // 📌 Store 객체 리스트
  final supabase = Supabase.instance.client;
  late Future<SharedPreferences> prefsFuture; // ✅ 추가
String getCategoryLabel(String code) {
  const labels = {
    '1': '한식',
    '2': '중식',
    '3': '일식',
    '4': '양식',
    '5': '카페',
    '6': '기타',
  };
  return labels[code] ?? '카테고리';
}


  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  void fetchStores() async {
  try {
    var response = await supabase
        .from("business_data")
        .select()
        .order("id", ascending: true);

    final allStores = response.map<business_data>((data) => business_data.fromMap(data)).toList();

    setState(() {
      if (widget.category == '6') {
        // '기타'는 모든 1~5 카테고리를 의미
        storeList = allStores
            .where((store) => [1, 2, 3, 4, 5].contains(store.category))
            .toList();
      } else {
        final int selectedCategory = int.tryParse(widget.category) ?? -1;
        storeList = allStores
            .where((store) => store.category == selectedCategory)
            .toList();
      }

      storeList.shuffle(); // ✅ 항상 셔플 (모든 카테고리에 적용)

      print("📊 최종 필터링된 가게 수: ${storeList.length}");
    });
  } catch (e) {
    print("❌ 오류 발생: $e");
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔥 배경색 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: Text(
  getCategoryLabel(widget.category),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black, // 버튼색이 스크롤에 의해 바뀌지 않도록
        surfaceTintColor: Colors.white, // 머티리얼 3 대응용 (앱바 배경 흐림 방지)
        shadowColor: Colors.transparent, // 그림자 투명화(선택)
      ),

      body: storeList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '해당하는 가게가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
              : ListView.builder(
                itemCount: storeList.length,
                itemBuilder: (context, index) {
                  return StoreCard(
                    store: storeList[index],
                    onTap: () async {
                      print("가게 클릭됨: ${storeList[index].name}"); // ✅ 클릭 로그
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  StoreDetailPage(store: storeList[index]),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
