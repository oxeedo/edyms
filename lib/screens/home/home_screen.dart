import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/chat_provider.dart';
import '../../router/app_router.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../services/home_service.dart';
import '../../services/course_service.dart';
import '../../models/home_data.dart';
import '../../models/banner.dart';
import '../../models/category.dart';
import '../../models/course.dart';
import '../../models/bundle.dart';
import '../categories/categories_screen.dart';
import '../category_detail/category_detail_screen.dart';
import '../courses/courses_screen.dart';
import '../course_detail/course_detail_screen.dart';
import '../bundles/bundle_detail_screen.dart';
import '../bundles/bundles_screen.dart';
import '../ai_suggestions/ai_suggestions_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../notifications/notifications_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/auth_screen.dart';
import '../../config/config.dart';
import '../../widgets/home_skeletons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final HomeService _homeService = HomeService();
  final CourseService _courseService = CourseService();
  double _savedScrollPosition = 0.0;

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CoursesScreen(initialSearchQuery: query),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  HomeData? _homeData;
  bool _isLoading = true;
  String? _error;

  // Pagination state for Recent Courses
  List<Course> _recentCourses = [];
  int _recentPage = 1;
  bool _isMoreRecentLoading = false;
  bool _hasMoreRecent = true;

  List<Bundle> _bundles = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreRecentCourses();
    }
  }

  Future<void> _fetchData() async {
    try {
      final response = await _homeService.fetchHomeData();
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          if (mounted) {
            setState(() {
              _homeData = HomeData.fromJson(jsonResponse);
              _recentCourses = _homeData?.recentCourses ?? [];
            });

            // Fetch bundles in parallel
            try {
              final bundleResponse = await _courseService.fetchBundles();
              if (bundleResponse.statusCode == 200) {
                final bData = jsonDecode(bundleResponse.body);
                if (bData['success'] == true && bData['data'] != null) {
                  setState(() {
                    _bundles = (bData['data'] as List)
                        .map((b) => Bundle.fromJson(b))
                        .toList();
                  });
                }
              }
            } catch (e) {
              // Ignore bundle fetch error
            }

            setState(() {
              _isLoading = false;
            });
          }
        } else {
          _handleError('Failed to load data');
        }
      } else {
        _handleError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Connection error: $e');
    }
  }

  Future<void> _loadMoreRecentCourses() async {
    if (_isMoreRecentLoading || !_hasMoreRecent) return;

    setState(() {
      _isMoreRecentLoading = true;
    });

    try {
      final response = await _courseService.fetchRecentCourses(
        page: _recentPage + 1,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          // Check if data is paginated (Laravel default: data -> data)
          final data = jsonResponse['data'];
          final List<dynamic> newCoursesJson =
              (data is Map && data.containsKey('data')) ? data['data'] : data;

          if (mounted) {
            setState(() {
              if (newCoursesJson.isNotEmpty) {
                _recentCourses.addAll(
                  newCoursesJson.map((json) => Course.fromJson(json)).toList(),
                );
                _recentPage++;
              } else {
                _hasMoreRecent = false;
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading more courses: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isMoreRecentLoading = false;
        });
      }
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _error = message;
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    if (_scrollController.hasClients) {
      _savedScrollPosition = _scrollController.offset;
    }

    await _fetchData();

    // Restore scroll position after refresh to prevent auto-scroll
    if (mounted && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          if (_savedScrollPosition > 0 &&
              _savedScrollPosition <=
                  _scrollController.position.maxScrollExtent) {
            _scrollController.jumpTo(_savedScrollPosition);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            const _HomeAppBar(),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.primary,
                displacement: 40,
                edgeOffset: 0,
                triggerMode: RefreshIndicatorTriggerMode.onEdge,
                child: _isLoading
                    ? const HomeSkeletons()
                    : _error != null
                    ? _buildErrorState()
                    : _buildMainContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: BottomNavTab.home),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => const AiCourseGeneratorInputScreen(),
      //       ),
      //     );
      //   },
      //   backgroundColor: AppTheme.getPrimaryColor(context),
      //   elevation: 0,
      //   child: const Icon(Icons.add, color: Colors.white, size: 28),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final data = _homeData;
    if (data == null) {
      return const Center(child: Text('No data found'));
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: <Widget>[
        const SliverToBoxAdapter(child: SizedBox(height: 12)), // Top spacing
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SearchRow(
              controller: _searchController,
              onSearch: _handleSearch,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _HeroBanner(banners: data.banners),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (data.categories.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeader(
                title: context.l10n.topCategories,
                actionText: context.l10n.seeAll,
                onSeeAllTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _TopCategoriesRow(categories: data.categories),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
        if (data.popularCourses.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeader(
                title: context.l10n.popularCourses,
                actionText: context.l10n.seeAll,
                onSeeAllTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CoursesScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _PopularCoursesRow(courses: data.popularCourses),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
        if (_bundles.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeader(
                title: 'Course Bundles',
                actionText: context.l10n.seeAll,
                onSeeAllTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BundlesScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _bundles.length,
                itemBuilder: (context, index) {
                  final bundle = _bundles[index];
                  final courseCount = bundle.courses?.length ?? 0;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BundleDetailScreen(bundle: bundle),
                        ),
                      );
                    },
                    child: Container(
                      width: 190,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(14),
                                ),
                                child: bundle.image != null
                                    ? Image.network(
                                        bundle.image!,
                                        height: 110,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, e, st) => Container(
                                          height: 110,
                                          color: Colors.grey.shade200,
                                          child: Icon(Icons.layers_outlined,
                                              color: Colors.grey.shade400, size: 32),
                                        ),
                                      )
                                    : Container(
                                        height: 110,
                                        width: double.infinity,
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.layers_outlined,
                                            color: Colors.grey.shade400, size: 32),
                                      ),
                              ),
                              if (courseCount > 0)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3C00),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$courseCount Courses',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bundle.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.getTextColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.read<SettingsProvider>().formatPrice(bundle.price),
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
        if (data.aiSuggestions.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeader(
                title: 'AI Suggestions',
                actionText: context.l10n.seeAll,
                onSeeAllTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AiSuggestionsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: _AiSuggestionsRow(courses: data.aiSuggestions),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
        if (_recentCourses.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeader(
                title: 'Most Recent',
                actionText: context.l10n.seeAll,
                onSeeAllTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CoursesScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          _MostRecentSection(
            courses: _recentCourses,
            isLoading: _isMoreRecentLoading,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ],
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        final bool isAuthenticated = auth.isAuthenticated;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (isAuthenticated) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: (isAuthenticated && user?.profilePhotoUrl != null)
                          ? NetworkImage(user!.profilePhotoUrl!)
                          : const AssetImage('assets/img/default-profile.png')
                                as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.hello,
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAuthenticated ? (user?.name ?? 'User') : 'Guest',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const WishlistScreen(),
                        ),
                      );
                    },
                    child: Consumer<WishlistProvider>(
                      builder: (context, provider, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.favorite_border,
                                  size: 18,
                                  color: AppTheme.getTextColor(context),
                                ),
                              ),
                            ),
                            if (provider.itemCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4B4B),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.getCardColor(context),
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${provider.itemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRouter.messages);
                    },
                    child: Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedBubbleChat,
                                  size: 18,
                                  color: AppTheme.getTextColor(context),
                                ),
                              ),
                            ),
                            if (chatProvider.unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4B4B),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.getCardColor(context),
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 14,
                                    minHeight: 14,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${chatProvider.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedNotification01,
                              size: 18,
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.getBackgroundColor(context),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          TextField(
            controller: controller,
            onSubmitted: onSearch,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.getCardColor(context),
              hintText: context.l10n.search,
              hintStyle: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.65),
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ).copyWith(right: 52),
            ),
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 14,
            ),
          ),
          Positioned(
            right: 6,
            child: GestureDetector(
              onTap: () => onSearch(controller.text),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.banners});

  final List<BannerModel> banners;

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }
    return _HeroBannerSlider(banners: banners);
  }
}

class _HeroBannerSlider extends StatefulWidget {
  const _HeroBannerSlider({required this.banners});

  final List<BannerModel> banners;

  @override
  State<_HeroBannerSlider> createState() => _HeroBannerSliderState();
}

class _HeroBannerSliderState extends State<_HeroBannerSlider> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (int index) => setState(() => _page = index),
            itemCount: widget.banners.length,
            itemBuilder: (BuildContext context, int index) {
              final banner = widget.banners[index];
              return Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: banner.imagePath != null
                    ? _LazyNetworkImage(banner.imagePath!)
                    : Container(color: Colors.grey[300]),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.banners.length, (int index) {
            final bool isActive = index == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              width: isActive ? 16 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primary
                    : AppTheme.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    this.onSeeAllTap,
  });

  final String title;
  final String actionText;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAllTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopCategoriesRow extends StatelessWidget {
  const _TopCategoriesRow({required this.categories});

  final List<Category> categories;

  IconData _getCategoryIcon(String? iconName) {
    if (iconName == null) return Icons.grid_view_rounded;

    // Map FontAwesome class names to Material Icons (approximate)
    switch (iconName) {
      case 'fas fa-code':
        return Icons.code_rounded;
      case 'fas fa-pencil-ruler':
        return Icons.design_services_rounded;
      case 'fas fa-briefcase':
        return Icons.business_center_rounded;
      case 'fas fa-chalkboard-teacher':
        return Icons.school_rounded; // or cast_for_education
      case 'fas fa-laptop-code':
        return Icons.computer_rounded;
      case 'fas fa-bullhorn':
        return Icons.campaign_rounded;
      case 'fas fa-camera':
        return Icons.camera_alt_rounded;
      case 'fas fa-music':
        return Icons.music_note_rounded;
      case 'fas fa-chart-line':
        return Icons.show_chart_rounded;
      case 'fas fa-utensils':
        return Icons.restaurant_rounded;
      case 'fas fa-heartbeat':
        return Icons.favorite_rounded;
      case 'fas fa-language':
        return Icons.language_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int index) {
          final Category category = categories[index];
          // Simple color generation or mapping could be here. Using default for now.
          final Color background = AppTheme.primary.withValues(alpha: 0.1);

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
              width: 100,
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned.fill(
                    top: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Floating circular icon slightly above the card
                  Positioned(
                    top: 2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: background,
                          border: Border.all(
                            color: AppTheme.getCardColor(context),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(category.icon), // Default icon
                            size: 24,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helper widget for network images with lazy loading effect
class _LazyNetworkImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;

  const _LazyNetworkImage(this.path, {this.width, this.height});

  @override
  Widget build(BuildContext context) {
    // Use AppConfig helper to resolve URL
    final String url = AppConfig.getImageUrl(path);

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: Icon(Icons.image, color: Colors.grey[400], size: 24),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}

class _PopularCoursesRow extends StatelessWidget {
  const _PopularCoursesRow({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    if (courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (BuildContext context, int index) {
          final Course course = courses[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(courseId: course.id),
                ),
              );
            },
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: AppTheme.getSoftGray150(context),
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Container(
                          color: AppTheme.mint200,
                          child: course.thumbnail != null
                              ? _LazyNetworkImage(course.thumbnail!)
                              : Container(color: Colors.grey[300]),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppTheme.getCardColor(
                                context,
                              ).withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedBookmark01,
                                size: 14,
                                color: AppTheme.getTextColor(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedPlay,
                              size: 12,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.lessonsCount} ${context.l10n.lessons}',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedStar,
                              size: 12,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.rating ?? 0.0} (${course.reviewsCount})',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (course.discountedPrice != null &&
                                course.discountedPrice! <
                                    (course.price ?? 0)) ...[
                              Text(
                                settingsProvider.formatPrice(
                                  course.discountedPrice,
                                ),
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                settingsProvider.formatPrice(course.price),
                                style: TextStyle(
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.5),
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ] else
                              Text(
                                course.price != null
                                    ? settingsProvider.formatPrice(course.price)
                                    : 'Free',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiSuggestionsRow extends StatelessWidget {
  const _AiSuggestionsRow({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    if (courses.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (BuildContext context, int index) {
          final Course course = courses[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(courseId: course.id),
                ),
              );
            },
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: AppTheme.getSoftGray150(context),
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 110,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Container(
                          color: AppTheme.mint200,
                          child: course.thumbnail != null
                              ? _LazyNetworkImage(course.thumbnail!)
                              : Container(color: Colors.grey[300]),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppTheme.getCardColor(
                                context,
                              ).withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedBookmark01,
                                size: 14,
                                color: AppTheme.getTextColor(context),
                              ),
                            ),
                          ),
                        ),
                        // AI Badge
                        Positioned(
                          left: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.auto_awesome,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedPlay,
                              size: 12,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.lessonsCount} ${context.l10n.lessons}',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedStar,
                              size: 12,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.rating ?? 0.0} (${course.reviewsCount})',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (course.discountedPrice != null &&
                                course.discountedPrice! <
                                    (course.price ?? 0)) ...[
                              Text(
                                settingsProvider.formatPrice(
                                  course.discountedPrice,
                                ),
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                settingsProvider.formatPrice(course.price),
                                style: TextStyle(
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.5),
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ] else
                              Text(
                                course.price != null
                                    ? settingsProvider.formatPrice(course.price)
                                    : 'Free',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MostRecentSection extends StatelessWidget {
  const _MostRecentSection({required this.courses, this.isLoading = false});

  final List<Course> courses;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty && !isLoading) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final Course course = courses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(courseId: course.id),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.getSoftGray150(context),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Course image
                        Container(
                          width: 130,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.mint200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: course.thumbnail != null
                              ? _LazyNetworkImage(
                                  course.thumbnail!,
                                  width: 130,
                                  height: 100,
                                )
                              : Container(color: Colors.grey[300]),
                        ),
                        const SizedBox(width: 12),
                        // Course details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _MostRecentCourseDetails(course: course),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: courses.length),
          ),
        ),
        if (isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _MostRecentCourseDetails extends StatelessWidget {
  const _MostRecentCourseDetails({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          course.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            HugeIcon(
              icon: HugeIcons.strokeRoundedPlay,
              size: 11,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '${course.lessonsCount} ${context.l10n.lessons}',
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '·',
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ),
            HugeIcon(
              icon: HugeIcons.strokeRoundedStar,
              size: 11,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '${course.rating ?? 0.0} (${course.reviewsCount})',
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (course.discountedPrice != null &&
                course.discountedPrice! < (course.price ?? 0)) ...[
              Text(
                settingsProvider.formatPrice(course.discountedPrice),
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                settingsProvider.formatPrice(course.price),
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                  fontSize: 13,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ] else
              Text(
                course.price != null
                    ? settingsProvider.formatPrice(course.price)
                    : 'Free',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
