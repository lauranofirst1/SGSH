import 'package:flutter/material.dart';

class QnAPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 항상 흰색 유지

      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '문의하기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        children: const [
          ListTile(title: Text('문의하기'), subtitle: Text('lauran1@naver.com')),
        ],
      ),
    );
  }
}
