import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String> onChanged; // onChanged 콜백 추가

  SearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onChanged, // onChanged 파라미터 추가
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '찾고 싶은 장소를 입력하세요.',
                border: InputBorder.none,
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          controller.clear();
                          onChanged(''); // 입력된 내용 초기화 후 onChanged 호출
                        },
                      )
                    : null, // 텍스트가 있을 때만 X 버튼이 보임
              ),
              onSubmitted: onSubmitted,
              onChanged: onChanged, // onChanged도 TextField에 연결
            ),
          ),
        ],
      ),
    );
  }
}
