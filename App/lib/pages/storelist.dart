import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';
import 'package:app/models/business.dart'; // 📌 Store 모델 가져오기
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 📍 가게 리스트 페이지
class StoreListPage extends StatefulWidget {
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
          .order("id", ascending: true); // 🔥 id 기준 오름차순 정렬

      setState(() {
        storeList =
            response
                .map<business_data>((data) => business_data.fromMap(data))
                .toList(); // 🔥 변환 적용
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
        title: Text('맛집 추천'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),

      body:
          storeList.isEmpty
              ? Center(child: CircularProgressIndicator()) // 🔥 로딩 표시
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
