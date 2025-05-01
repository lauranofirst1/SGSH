import 'package:flutter/material.dart';

class ReservationSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 항상 흰색 유지

      appBar: AppBar(
        backgroundColor: Colors.white, // 항상 흰색 유지
        elevation: 0.5,
        centerTitle: false,
        title: const Text(
          '캘린더 자동 등록',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SwitchListTile(
        title: const Text('캘린더에 예약 자동 등록'),
        value: true,
        onChanged: (val) {
          // TODO: 설정 상태 저장 로직
        },
      ),
    );
  }
}
