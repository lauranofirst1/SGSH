import 'package:app/models/business.dart';
import 'package:app/pages/adpage.dart';
import 'package:app/pages/mappage.dart';
import 'package:app/pages/mypage.dart';
import 'package:app/pages/searchpage.dart';
import 'package:app/widgets/storedetailbottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/mainpage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
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

  runApp(
    MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFF2F2F7)),
      debugShowCheckedModeBanner: false,
      home: MyApp(), // ✅ 여기서 MyApp을 화면 자체로 쓸 것
    ),
  );
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  bool _isBottomNavVisible = true;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Mainpage(),
      SearchPage(),
      MapPage(onMarkerTap: _handleMarkerTap), // 💡 여기 중요!
      MyDiningPage(),
      MyPage(),
    ]);
  }

void _handleMarkerTap(String name, String address, business_data? store) {
  setState(() => _isBottomNavVisible = false);

  final controller = _scaffoldKey.currentState!.showBottomSheet(
    (context) => StoreDetailBottomSheet(
      name: name,
      address: address,
      store: store,
    ),
    backgroundColor: Colors.transparent,
  );

  controller.closed.then((_) {
    setState(() => _isBottomNavVisible = true);
  });
}



  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }


final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // 상태바 배경색
      statusBarIconBrightness: Brightness.dark, // 아이콘 색상 (검정)
      statusBarBrightness: Brightness.light, // iOS용
    ));

    return MaterialApp(
      
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFF2F2F7)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          key: _scaffoldKey, // 🔥 여기!
        backgroundColor: Color(0xFFF2F2F7),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: _isBottomNavVisible
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.white,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
                  BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
                  BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '즐겨찾기'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: '나의페이지'),
                ],
              )
            : null,
      ),
    );
  }
}
