import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();
  List<Course> _items = [];
  bool _isLoading = false;

  List<Course> get items => _items;
  int get itemCount => _items.length;
  bool get isLoading => _isLoading;

  WishlistProvider() {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    _isLoading = true;
    notifyListeners();
    _items = await _wishlistService.getWishlist();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleWishlist(Course course) async {
    await _wishlistService.toggleWishlist(course);
    await loadWishlist();
  }

  bool isInWishlist(int courseId) {
    return _items.any((item) => item.id == courseId);
  }
}
