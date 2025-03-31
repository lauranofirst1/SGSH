
// article_data
// id: 정렬용 인덱스
// title: 게시물 제목
// content: 게시물 내용
// author: 작성자
// time: 작성 시간


class article_data {
  final int id;
  final String title;
  final String content;
  final String author;
  final String time;


  article_data({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.time,

  });

  factory article_data.fromMap(Map<String, dynamic> data) {
    return article_data(
      id: data["id"] ?? 0,
      title: data["title"] ?? "이름 없음",
      content: data["content"] ?? "내용 없음",
      author: data["author"] ?? "작성자 없음",
      time: data["time"] ?? "시간 없음",
     
    );
  }
}
