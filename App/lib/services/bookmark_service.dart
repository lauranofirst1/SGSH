import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class BookmarkService {
  static const _key = 'bookmarkedStores';
  
  // 북마크 상태 변경을 알리는 스트림 컨트롤러
  static final _bookmarkController = StreamController<List<String>>.broadcast();
  static Stream<List<String>> get bookmarkStream => _bookmarkController.stream;

  static Future<List<String>> _getStoredIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_key) ?? [];
      print('📚 저장된 북마크 ID 목록: $ids');
      return ids;
    } catch (e) {
      print('❌ 북마크 ID 목록 가져오기 실패: $e');
      return [];
    }
  }

  static Future<void> toggleBookmark(String storeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = List<String>.from(await _getStoredIds());
      
      if (ids.contains(storeId)) {
        ids.remove(storeId);
        print('🗑️ 북마크 제거: $storeId');
      } else {
        ids.add(storeId);
        print('🔖 북마크 추가: $storeId');
      }
      
      final success = await prefs.setStringList(_key, ids);
      if (success) {
        print('✅ 북마크 상태 저장 성공');
        _bookmarkController.add(ids); // 상태 변경 알림
      } else {
        print('❌ 북마크 상태 저장 실패');
      }
    } catch (e) {
      print('❌ 북마크 토글 실패: $e');
    }
  }

  static Future<bool> isBookmarked(String storeId) async {
    try {
      final ids = await _getStoredIds();
      return ids.contains(storeId);
    } catch (e) {
      print('❌ 북마크 상태 확인 실패: $e');
      return false;
    }
  }

  static Future<List<String>> getBookmarkedIds() async {
    try {
      final ids = await _getStoredIds();
      // _bookmarkController.add(ids); // 현재 상태 알림 (무한루프 방지 위해 주석처리)
      return ids;
    } catch (e) {
      print('❌ 북마크 ID 목록 가져오기 실패: $e');
      return [];
    }
  }

  // 스트림 컨트롤러 정리
  static void dispose() {
    _bookmarkController.close();
  }
}
