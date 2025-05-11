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

      setState(() {
        final allStores = response.map<business_data>((data) => business_data.fromMap(data)).toList();
        
        // 카테고리별 필터링
        if (widget.category == '기타') {
          // 기타 카테고리에는 모든 매장 포함
          storeList = allStores;
        } else {
          // 특정 카테고리에 해당하는 매장만 필터링
          storeList = allStores.where((store) => store.category == widget.category).toList();
        }
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
          widget.category,
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
