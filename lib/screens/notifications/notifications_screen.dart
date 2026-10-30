import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../course_detail/course_detail_screen.dart';
import '../common/webview_screen.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../widgets/image_modal.dart';
import '../../config/config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isMessagesLoading = true;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadNotifications(loadMore: true);
    }
  }

  Future<void> _loadNotifications({bool loadMore = false}) async {
    if (_isLoading) return;

    if (!loadMore) {
      setState(() {
        _isMessagesLoading = true;
        _currentPage = 1;
        _notifications = [];
      });
    }

    setState(() => _isLoading = true);

    try {
      final response = await _notificationService.fetchNotifications(
        page: _currentPage,
      );

      setState(() {
        if (loadMore) {
          _notifications.addAll(response.notifications);
        } else {
          _notifications = response.notifications;
        }
        _currentPage++;
        _lastPage = response.lastPage;
        _hasMore = _currentPage <= _lastPage;
        _isLoading = false;
        _isMessagesLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isMessagesLoading = false;
      });
      // Show error
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      setState(() {
        final int index = _notifications.indexWhere(
          (n) => n.id == notificationId,
        );
        if (index != -1) {
          final old = _notifications[index];
          _notifications[index] = NotificationModel(
            id: old.id,
            title: old.title,
            message: old.message,
            type: old.type,
            image: old.image,
            url: old.url,
            readAt: DateTime.now(),
            createdAt: old.createdAt,
          );
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllRead();
      setState(() {
        _notifications = _notifications.map((n) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            image: n.image,
            url: n.url,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
          );
        }).toList();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
      });
    } catch (e) {
      // Handle error
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    switch (notification.type) {
      case 'image':
        if (notification.image != null) {
          showDialog(
            context: context,
            builder: (context) => ImageModal(
              imageUrl: notification.image!.startsWith('http')
                  ? notification.image!
                  : '${AppConfig.baseUrl}/storage/${notification.image}',
              title: notification.title,
            ),
          );
        }
        break;
      case 'url':
        if (notification.url != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WebViewScreen(
                url: notification.url!,
                title: notification.title,
              ),
            ),
          );
        }
        break;
      case 'course':
        // Extract ID from URL or add source_id to model
        final uri = Uri.tryParse(notification.url ?? '');
        final id = uri?.pathSegments.last;
        if (id != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(courseId: int.parse(id)),
            ),
          );
        }
        break;
      // Handle 'author' type if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: <Widget>[
          // Background decorative shapes
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: isDarkMode
                ? Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: _BackgroundPainter(
                      color1: AppTheme.getMint100(context),
                      color2: AppTheme.getMint200(context),
                    ),
                    child: Container(),
                  ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                // App Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: isDarkMode
                      ? BoxDecoration(
                          color: AppTheme.primaryDark,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        )
                      : null,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          size: 20,
                          color: isDarkMode
                              ? Colors.white
                              : AppTheme.getTextColor(context),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Text(
                          'Notifications',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : AppTheme.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      if (_unreadCount > 0 && _notifications.isNotEmpty)
                        TextButton(
                          onPressed: _markAllAsRead,
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : AppTheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                    ],
                  ),
                ),
                // Notifications List
                Expanded(
                  child: _isMessagesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => _loadNotifications(),
                          child: _notifications.isEmpty
                              ? _EmptyNotificationsState()
                              : ListView.separated(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  itemCount:
                                      _notifications.length +
                                      (_hasMore ? 1 : 0),
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                        if (index == _notifications.length) {
                                          return const Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        }

                                        final NotificationModel notification =
                                            _notifications[index];
                                        return _NotificationCard(
                                          notification: notification,
                                          onTap: () => _handleNotificationTap(
                                            notification,
                                          ),
                                          onDelete: () => _deleteNotification(
                                            notification.id,
                                          ),
                                        );
                                      },
                                ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData _getIcon() {
    switch (notification.type) {
      case 'course':
        return Icons.refresh;
      case 'image':
        return Icons.image;
      case 'url':
        return Icons.link;
      case 'author':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (notification.type) {
      case 'course':
        return AppTheme.primary;
      case 'image':
        return Colors.blue;
      case 'url':
        return Colors.green;
      case 'author':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final IconData icon = _getIcon();
    final Color iconColor = _getIconColor(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppTheme.getCardColor(context)
                : (isDarkMode
                      ? AppTheme.surfaceDark.withValues(alpha: 0.6)
                      : AppTheme.getMint100(context).withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead
                ? null
                : Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, size: 24, color: iconColor)),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy · hh:mm a',
                      ).format(notification.createdAt),
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedNotification01,
                  size: 60,
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications',
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'re all caught up!\nNew notifications will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({required this.color1, required this.color2});

  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.6,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);

    final Paint paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    final Path path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width,
        size.height * 0.7,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
