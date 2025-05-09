import 'package:app/auth/loginpage.dart';
import 'package:app/models/userprofile.dart';
import 'package:app/pages/mydiningpage.dart';
import 'package:app/pages/mappage.dart';
import 'package:app/pages/mypage.dart';
import 'package:app/pages/searchpage.dart';
import 'package:app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:app/pages/mainpage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['PROJECT_URL'] ?? '',
    anonKey: dotenv.env['PROJECT_API_KEY'] ?? '',
  );

  final user = Supabase.instance.client.auth.currentUser;

  if (user != null) {
    print("✅ 로그인 유지됨: ${user.email}");
  } else {
    print("❌ 로그인 안됨. LoginPage로 이동.");
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginPage() : MyApp(),
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
  UserProfile? _userProfile; // 꼭 추가하세요!

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Mainpage(),
      SearchPage(),
      MapPage(), // 💡 여기 중요!
      MyDiningPage(),
      MyPage(),
    ]);
    _loadUserProfile(); // 🔥 유저 정보 불러오기
  }

  Future<void> _loadUserProfile() async {
    final profile = await SupabaseService().getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  // void _handleMarkerTap(String name, String address, business_data? store) {
  //   setState(() => _isBottomNavVisible = false);

  //   final controller = _scaffoldKey.currentState!.showBottomSheet(
  //     (context) =>
  //         StoreDetailBottomSheet(name: name, address: address, store: store),
  //     backgroundColor: Colors.transparent,
  //   );

  //   controller.closed.then((_) {
  //     setState(() => _isBottomNavVisible = true);
  //   });
  // }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // 상태바 배경색
        statusBarIconBrightness: Brightness.dark, // 아이콘 색상 (검정)
        statusBarBrightness: Brightness.light, // iOS용
      ),
    );

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      print('🟢 사용자 UID: ${user.id}');
      print('🟢 사용자 이메일: ${user.email}');
    }

    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFFF2F2F7)),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey, // 🔥 여기!
        backgroundColor: Color(0xFFF2F2F7),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar:
            _isBottomNavVisible
                ? BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.grey,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: '검색',
                    ),
                    BottomNavigationBarItem(icon: Icon(Icons.map), label: '지도'),
                    BottomNavigationBarItem(
                      // ✅ 여기만 변경됨!
                      icon: Icon(Icons.event_note), // 아이콘 교체
                      label: '나의 예약',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: '나의페이지',
                    ),
                  ],
                )
                : null,
      ),
    );
  }
}
