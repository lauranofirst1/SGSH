import 'package:app/pages/likepage.dart';
import 'package:app/pages/mappage.dart';
import 'package:app/pages/mypage.dart';
import 'package:app/pages/searchpage.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/mainpage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {  WidgetsFlutterBinding.ensureInitialized(); // 중요!

  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env 파일 로드 완료!");
  } catch (e) {
    print("❌ .env 파일 로드 실패: $e");
  }

  await Supabase.initialize(
    url: dotenv.env["PROJECT_URL"] ?? "",
    anonKey: dotenv.env["PROJECT_API_KEY"] ?? "",
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // 현재 선택된 인덱스

  final List<Widget> _pages = [
    Mainpage(),
    SearchPage(),
    MapPage(),
    LikesPage(),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFF2F2F7)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF2F2F7), // iOS systemGroupedBackground 느낌

        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black, // 선택된 아이콘 색상
          unselectedItemColor: Colors.grey, // 선택되지 않은 아이콘 색상
          type: BottomNavigationBarType.fixed, // 5개 아이콘을 사용할 때 필요
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '즐겨찾기'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '나의페이지'),
          ],
        ),
      ),
    );
  }
}
