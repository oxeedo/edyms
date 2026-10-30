import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/bundle.dart';
import '../../services/course_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'bundle_detail_screen.dart';

class BundlesScreen extends StatefulWidget {
  const BundlesScreen({super.key});

  @override
  State<BundlesScreen> createState() => _BundlesScreenState();
}

class _BundlesScreenState extends State<BundlesScreen> {
  final CourseService _service = CourseService();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List<Bundle> _bundles = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
        _bundles = [];
      });
    }
    try {
      final res = await _service.fetchBundlesPage(page: _page, search: _search);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List raw = data['data'] ?? [];
        final newBundles = raw.map((b) => Bundle.fromJson(b)).toList();
        setState(() {
          if (reset) {
            _bundles = newBundles;
          } else {
            _bundles.addAll(newBundles);
          }
          _hasMore = newBundles.length >= 12;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load bundles';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    try {
      final res = await _service.fetchBundlesPage(page: _page, search: _search);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List raw = data['data'] ?? [];
        final newBundles = raw.map((b) => Bundle.fromJson(b)).toList();
        setState(() {
          _bundles.addAll(newBundles);
          _hasMore = newBundles.length >= 12;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingMore = false);
  }

  void _onSearch(String val) {
    _search = val.trim();
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Course Bundles', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.getCardColor(context),
        foregroundColor: AppTheme.getTextColor(context),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppTheme.getCardColor(context),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: _onSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search bundles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.getBackgroundColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _bundles.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: () => _load(reset: true),
                            color: AppTheme.primary,
                            child: GridView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: _bundles.length + (_isLoadingMore ? 2 : 0),
                              itemBuilder: (context, i) {
                                if (i >= _bundles.length) {
                                  return const Card(
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return _BundleCard(bundle: _bundles[i]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.withValues(alpha: 0.7)),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _load(reset: true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.layers_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _search.isNotEmpty ? 'No bundles found for "$_search"' : 'No bundles available yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      );
}

class _BundleCard extends StatelessWidget {
  final Bundle bundle;
  const _BundleCard({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final courseCount = bundle.courses?.length ?? 0;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BundleDetailScreen(bundle: bundle)),
      ),
      child: Container(
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
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: bundle.image != null
                      ? Image.network(
                          bundle.image!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, st) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                if (courseCount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3C00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$courseCount Courses',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Provider.of<SettingsProvider>(context, listen: false).formatPrice(bundle.price),
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 110,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Icon(Icons.layers_outlined, color: Colors.grey.shade400, size: 32),
      );
}
