import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../category_detail/category_detail_screen.dart';
import '../../models/category.dart';
import '../../services/course_service.dart';
import '../../config/config.dart';
import 'categories_skeletons.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CourseService _courseService = CourseService();
  final TextEditingController _searchController = TextEditingController();

  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String? _error;
  bool _isSearchExpanded = false;

  // Colors palette to cycle through for category cards
  final List<Color> _cardColors = const [
    Color(0xFFD6E7E0), // Greenish
    Color(0xFFD7E5EC), // Blueish
    Color(0xFFFFE3C9), // Orangeish
    Color(0xFFE5D8FF), // Purpleish
    Color(0xFFFFD6E5), // Pinkish
    Color(0xFFD6E7FF), // Blue
    Color(0xFFFFF4D6), // Yellow
    Color(0xFFE0F0E0), // Light Green
    Color(0xFFE8F4F8), // Light Blue
    Color(0xFFF0E8FF), // Light Purple
    Color(0xFFE6F3F0), // Mint
    Color(0xFFFFF0E6), // Peach
  ];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = List.from(_allCategories);
      } else {
        _filteredCategories = _allCategories.where((category) {
          return category.name.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _courseService.fetchCategories();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> categoriesList = data['data'];
          final categories = categoriesList
              .map((json) => Category.fromJson(json))
              .toList();
          setState(() {
            _allCategories = categories;
            _filteredCategories = categories;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Failed to load categories';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load categories: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSearchExpanded
                          ? SizedBox(
                              key: const ValueKey('search'),
                              height: 40,
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: '${context.l10n.search}...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            )
                          : Text(
                              context.l10n.topCategories,
                              key: const ValueKey('title'),
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                  IconButton(
                    icon: HugeIcon(
                      icon: _isSearchExpanded
                          ? HugeIcons.strokeRoundedCancel01
                          : HugeIcons.strokeRoundedSearch01,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = !_isSearchExpanded;
                        if (!_isSearchExpanded) {
                          _searchController.clear();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Categories Grid
            Expanded(
              child: _isLoading
                  ? const CategoriesSkeleton()
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!),
                          ElevatedButton(
                            onPressed: _fetchCategories,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchCategories,
                      child: Stack(
                        children: [
                          CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: <Widget>[
                              if (_filteredCategories.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 100),
                                      child: Text(
                                        'No categories found',
                                        style: TextStyle(
                                          color: AppTheme.getTextColor(
                                            context,
                                          ).withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else ...[
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    100,
                                  ),
                                  sliver: SliverGrid.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 20,
                                          childAspectRatio: 1.25,
                                        ),
                                    itemCount: _filteredCategories.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final category =
                                              _filteredCategories[index];
                                          final color =
                                              _cardColors[index %
                                                  _cardColors.length];
                                          return _CategoryCard(
                                            category: category,
                                            backgroundColor: color,
                                          );
                                        },
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Bottom gradient fade effect
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 80,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      AppTheme.getBackgroundColor(
                                        context,
                                      ).withValues(alpha: 0),
                                      AppTheme.getBackgroundColor(
                                        context,
                                      ).withValues(alpha: 0.7),
                                      AppTheme.getBackgroundColor(context),
                                    ],
                                    stops: const <double>[0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.backgroundColor});

  final Category category;
  final Color backgroundColor;

  Widget _buildIcon(BuildContext context) {
    if (category.icon != null && category.icon!.startsWith('http')) {
      if (category.icon!.endsWith('.svg')) {
        return SvgPicture.network(
          AppConfig.getImageUrl(category.icon),
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(AppTheme.primary, BlendMode.srcIn),
          placeholderBuilder: (context) => HugeIcon(
            icon: HugeIcons.strokeRoundedLayers01,
            size: 28,
            color: AppTheme.primary,
          ),
        );
      } else {
        return Image.network(
          AppConfig.getImageUrl(category.icon),
          width: 28,
          height: 28,
          color: AppTheme.primary,
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
        );
      }
    }

    // Map common fontawesome names or slugs to HugeIcons
    // This handles "fontawesome icons already stored" case effectively
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    final slug = category.slug?.toLowerCase() ?? category.name.toLowerCase();
    dynamic iconData = HugeIcons.strokeRoundedLayers01;

    if (slug.contains('design')) {
      iconData = HugeIcons.strokeRoundedPenTool02;
    } else if (slug.contains('dev') ||
        slug.contains('code') ||
        slug.contains('program')) {
      iconData = HugeIcons.strokeRoundedCode;
    } else if (slug.contains('business') || slug.contains('market')) {
      iconData = HugeIcons.strokeRoundedMarketing;
    } else if (slug.contains('finance') || slug.contains('money')) {
      iconData = HugeIcons.strokeRoundedMoney03;
    } else if (slug.contains('photo') || slug.contains('camera')) {
      iconData = HugeIcons.strokeRoundedCamera01;
    } else if (slug.contains('music') || slug.contains('audio')) {
      iconData = HugeIcons.strokeRoundedMusicNote01;
    } else if (slug.contains('video') || slug.contains('film')) {
      iconData = HugeIcons.strokeRoundedVideo01;
    } else if (slug.contains('health') || slug.contains('fit')) {
      iconData = HugeIcons.strokeRoundedHealth;
    } else if (slug.contains('data') || slug.contains('science')) {
      iconData = HugeIcons.strokeRoundedBrowser;
    } else if (slug.contains('lang')) {
      iconData = HugeIcons.strokeRoundedGlobalEducation;
    } else if (slug.contains('art')) {
      iconData = HugeIcons.strokeRoundedPaintBoard;
    }

    return HugeIcon(icon: iconData, size: 28, color: AppTheme.primary);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryId: category.id,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: SizedBox(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Main card
            Positioned.fill(
              top: 30,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // We don't have course count in basic Category model yet,
                    // but we can add it or just hide it for now.
                    // Assuming we might not have it, let's just show "Explore" or similar
                    // Or if we updated API to return count, we could use it.
                    // For now, let's keep it simple.
                    Text(
                      context.l10n.view,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primary.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating circular icon slightly above the card
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundColor,
                    border: Border.all(
                      color: AppTheme.getCardColor(context),
                      width: 2.5,
                    ),
                  ),
                  child: Center(child: _buildIcon(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
