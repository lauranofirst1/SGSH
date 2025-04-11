import 'package:flutter/material.dart';
import 'package:app/models/article.dart'; // 실제 구조에 맞게 경로 조정 필요

class Articlepage extends StatelessWidget {
  final article_data article;

  Articlepage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Article Detail', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "by ${article.author} - ${_formatDateTime(article.time)}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 10),

            Container(height: 1, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              article.content,
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String datetime) {
    // 여기서 날짜 형식을 변경하는 함수를 추가할 수 있습니다.
    // 예시로 간단한 변경을 적용하였습니다.
    return datetime; // 실제로는 DateTime.parse()와 DateFormat을 사용하여 날짜 형식을 변경합니다.
  }
}
