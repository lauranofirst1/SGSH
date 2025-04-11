import 'package:flutter/material.dart';

String getStoreStatus(String timeRange) {
  final now = TimeOfDay.now();

  final parts = timeRange.split('~');
  if (parts.length != 2) return '시간 정보 오류';

  final start = _parseKoreanTime(parts[0].trim());
  final end = _parseKoreanTime(parts[1].trim());

  final nowMin = now.hour * 60 + now.minute;
  final startMin = start.hour * 60 + start.minute;
  final endMin = end.hour * 60 + end.minute;

  String formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  // 곧 오픈 (1시간 이내)
  if (nowMin < startMin && startMin - nowMin <= 60) {
    return '곧 영업 시작 • ${formatTime(start)}';
  }

  // 영업중
  if (startMin <= nowMin && nowMin < endMin - 60) {
    return '영업중 • ${formatTime(start)} - ${formatTime(end)}';
  }

  // 마감 1시간 이내
  if (endMin - nowMin <= 60 && nowMin < endMin) {
    return '곧 영업 마감 • ${formatTime(end)}';
  }

  // 마감 이후
 return '영업 마감 • ${formatTime(end)} 오픈시작';}

// 한글 시간 ("오전 10시", "오후 3시") → TimeOfDay 변환
TimeOfDay _parseKoreanTime(String timeStr) {
  final isPM = timeStr.contains('오후');
  final isAM = timeStr.contains('오전');

  final hourMatch = RegExp(r'(\d{1,2})시').firstMatch(timeStr);
  final minuteMatch = RegExp(r'(\d{1,2})분').firstMatch(timeStr);

  int hour = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
  int minute = minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;

  if (isPM && hour < 12) hour += 12;
  if (isAM && hour == 12) hour = 0; // 오전 12시는 0시

  return TimeOfDay(hour: hour, minute: minute);
}
