import 'package:app/auth/loginpage.dart';
import 'package:app/models/business.dart';
import 'package:app/models/userprofile.dart';
import 'package:app/pages/mydiningpage.dart';
import 'package:app/pages/mappage.dart';
import 'package:app/pages/mypage.dart';
import 'package:app/pages/searchpage.dart';
import 'package:app/services/supabase_service.dart';
import 'package:app/widgets/storedetailbottomsheet.dart';
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
      theme: ThemeData(
        primaryColor: Color(0xFF2D3436),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2D3436),
          secondary: Color(0xFF0984E3),
          surface: Colors.white,
          background: Color(0xFFF7F7F7),
        ),
        fontFamily: 'Pretendard',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
            letterSpacing: -0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF2D3436)),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2D3436),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF2D3436),
            side: BorderSide(color: Color(0xFF2D3436)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3436),
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
            letterSpacing: -0.5,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF2D3436),
            letterSpacing: -0.3,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3436),
            letterSpacing: -0.3,
            height: 1.5,
          ),
        ),
      ),
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
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      print('🟢 사용자 UID: ${user.id}');
      print('🟢 사용자 이메일: ${user.email}');
    }

    return Scaffold(
      key: _scaffoldKey,
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
                    icon: Icon(Icons.event_note),
                    label: '나의 예약',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: '나의페이지',
                  ),
                ],
              )
              : null,
    );
  }
}
