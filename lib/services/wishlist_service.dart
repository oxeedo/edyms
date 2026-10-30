import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';

class WishlistService {
  static const String _wishlistKey = 'wishlist_items';

  Future<List<Course>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wishlistData = prefs.getString(_wishlistKey);
    if (wishlistData == null) return [];

    try {
      final List<dynamic> decodedData = jsonDecode(wishlistData);
      return decodedData.map((item) => Course.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveWishlist(List<Course> courses) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      courses.map((c) => c.toJson()).toList(),
    );
    await prefs.setString(_wishlistKey, encodedData);
  }

  Future<void> toggleWishlist(Course course) async {
    final List<Course> wishlist = await getWishlist();
    final int index = wishlist.indexWhere((item) => item.id == course.id);

    if (index >= 0) {
      wishlist.removeAt(index);
    } else {
      wishlist.add(course);
    }

    await saveWishlist(wishlist);
  }

  Future<bool> isInWishlist(int courseId) async {
    final wishlist = await getWishlist();
    return wishlist.any((item) => item.id == courseId);
  }
}
