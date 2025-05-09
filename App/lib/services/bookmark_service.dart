import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const _key = 'bookmarkedStores';

  static Future<List<String>> _getStoredIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> toggleBookmark(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getStoredIds();
    if (ids.contains(storeId)) {
      ids.remove(storeId);
    } else {
      ids.add(storeId);
    }
    await prefs.setStringList(_key, ids);
  }

  static Future<bool> isBookmarked(String storeId) async {
    final ids = await _getStoredIds();
    return ids.contains(storeId);
  }

  static Future<List<String>> getBookmarkedIds() async {
    return await _getStoredIds();
  }
}
