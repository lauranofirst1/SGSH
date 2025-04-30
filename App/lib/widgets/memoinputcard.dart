import 'package:flutter/material.dart';
import '../services/memo_storage.dart';

class MemoInputCard extends StatefulWidget {
  final String memoKey;
  const MemoInputCard({super.key, required this.memoKey});

  @override
  State<MemoInputCard> createState() => _MemoInputCardState();
}

class _MemoInputCardState extends State<MemoInputCard> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMemo();
  }

  Future<void> _loadMemo() async {
    final memo = await loadMemo(widget.memoKey);
    _controller.text = memo ?? '';
  }

  void _onChanged(String value) {
    saveMemo(widget.memoKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: const InputDecoration(
          hintText: '나만의 메모를 남겨보세요',
          border: InputBorder.none,
          isCollapsed: true,
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black),
        maxLines: null,
      ),
    );
  }
}
