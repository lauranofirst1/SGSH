import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 항상 흰색 유지

      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '내 정보 수정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: const Center(child: Text('계정 정보 수정 페이지입니다.')),
    );
  }
}
