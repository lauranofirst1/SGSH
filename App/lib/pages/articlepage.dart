import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:app/models/article.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArticlePage extends StatefulWidget {
  final article_data article;

  const ArticlePage({Key? key, required this.article}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<article_data> recommendedArticles = [];

  @override
  void initState() {
    super.initState();
    fetchRecommendedArticles();
  }

  void fetchRecommendedArticles() async {
    try {
      final response = await supabase
          .from('article_data')
          .select()
          .eq('type', widget.article.type)
          .neq('id', widget.article.id); // 자기 자신 제외

      final list = response.map((e) => article_data.fromMap(e)).toList();
      list.shuffle(Random());

      setState(() {
        recommendedArticles = list.take(5).toList();
        isLoading = false;
      });
    } catch (e) {
      print("❌ 추천 아티클 로딩 실패: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '가치가게',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔶 대표 이미지 + 제목
                    Stack(
                      children: [
                        Image.network(
                          article.image ?? '',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: double.infinity,
                                height: 220,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image, size: 40),
                              ),
                        ),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          child: Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black45, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// 🔶 본문 + 작성자
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Html(data: article.content),
                          const SizedBox(height: 10),
                         Padding(padding: EdgeInsets.only(left: 10),child: 
                          Text(
                            "by ${article.author} - ${_formatDateTime(article.time)}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),)
                        ],
                      ),
                    ),

                    /// 🔽 추천 아티클
                    if (recommendedArticles.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 40, 20, 12),
                        child: Text(
                          "이런 글도 있어요",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: recommendedArticles.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final a = recommendedArticles[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArticlePage(article: a),
                                  ),
                                );
                              },
                              child: Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                    image: NetworkImage(a.image ?? ''),
                                    fit: BoxFit.cover,
                                    onError: (_, __) {},
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.5),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        a.desc ?? '', // 부제목/설명
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ],
                ),
              ),
    );
  }

  String _formatDateTime(String datetime) {
    return datetime; // 실제 DateTime 처리 원하면 format 추가
  }
}
