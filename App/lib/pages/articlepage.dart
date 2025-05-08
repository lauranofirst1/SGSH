import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:app/models/article.dart'; // 경로 확인 필요

class Articlepage extends StatelessWidget {
  final article_data article;

  Articlepage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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

            // HTML 렌더링
            Html(
              data: article.content,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String datetime) {
    return datetime; // DateTime 처리 가능
  }
}
