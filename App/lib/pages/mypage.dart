import 'package:app/pages/likepage.dart';
import 'package:flutter/material.dart';
import 'package:app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final UserData user = UserData(
    name: "홍길동",
    email: "hong@example.com",
    joinDate: "2024-01-15",
  );

  // 최근 본 기록 삭제 함수 추가
  void clearRecentStores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentStores');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('최근 본 기록이 삭제되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("나의 페이지", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.account_circle, size: 100, color: Colors.black45),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                user.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: Text(
                user.email,
                style: TextStyle(fontSize: 16, color: Colors.black54, fontStyle: FontStyle.italic),
              ),
            ),
            Divider(height: 40, thickness: 1, color: Colors.black26),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                SizedBox(width: 10),
                Text(
                  "가입 날짜: ${user.joinDate}",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: (){
                 Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LikesPage(),
                        ),
                      );},
                label: Text(
                  "즐겨찾기",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 145, 145, 145),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                onPressed: clearRecentStores,
                icon: Icon(Icons.delete_outline, color: Colors.white),
                label: Text(
                  "최근 본 기록 지우기",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.logout, color: Colors.black54),
                label: Text(
                  "로그아웃",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
