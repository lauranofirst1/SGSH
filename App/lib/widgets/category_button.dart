import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final List<String> categories;

  const CategoryButton({
    super.key,
    this.categories = const ['춘천시 교통', '데이트', '당일치기', '전시회'],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => Chip(
          label: Text(categories[index]),
          backgroundColor: Colors.green.shade100,
        ),
      ),
    );
  }
}
