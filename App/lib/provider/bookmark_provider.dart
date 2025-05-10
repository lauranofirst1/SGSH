// // lib/provider/bookmark_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BookmarkProvider with ChangeNotifier {
//   List<String> _bookmarkedIds = [];

//   List<String> get bookmarkedIds => _bookmarkedIds;

//   Future<void> loadBookmarks() async {
//     final prefs = await SharedPreferences.getInstance();
//     _bookmarkedIds = prefs.getStringList('bookmarkedStores') ?? [];
//     notifyListeners(); // ✅ 모든 위젯 리빌드
//   }

//   Future<void> toggleBookmark(String storeId) async {
//     final prefs = await SharedPreferences.getInstance();
//     if (_bookmarkedIds.contains(storeId)) {
//       _bookmarkedIds.remove(storeId);
//     } else {
//       _bookmarkedIds.add(storeId);
//     }
//     await prefs.setStringList('bookmarkedStores', _bookmarkedIds);
//     notifyListeners(); // ✅ 반영
//   }

//   bool isBookmarked(String storeId) => _bookmarkedIds.contains(storeId);
// /// ✅ 이 메서드를 추가해 주세요!
//   Future<List<String>> getBookmarkedIds() async {
//     return _bookmarkedIds;
//   }
// }
