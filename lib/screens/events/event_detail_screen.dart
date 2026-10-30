import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/event.dart';
import '../../config/config.dart';

import '../dashboard/my_ticket_bookings_screen.dart';
import 'ticket_booking_screen.dart';
import '../../models/instructor.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event});

  final Event event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isExpanded = false;
  bool _isEventInfoExpanded = false;

  String _formatDate(DateTime date) {
    final List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDayOfWeek(DateTime date) {
    final List<String> days = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _formatFullDate(DateTime date) {
    return '${_formatDayOfWeek(date)}, ${_formatDate(date)}';
  }

  Future<void> _showShareSheet(BuildContext context) async {
    final String url = '${AppConfig.baseUrl}/events/${widget.event.id}';
    await SharePlus.instance.share(
      ShareParams(text: 'Check out this event: ${widget.event.title}\n$url'),
    );
  }

  Future<void> _openMaps() async {
    final String query = Uri.encodeComponent(
      widget.event.locationDescription ?? widget.event.location ?? 'Dhaka',
    );
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    final Uri appleMapsUri = Uri.parse('http://maps.apple.com/?q=$query');

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else if (await canLaunchUrl(appleMapsUri)) {
      await launchUrl(appleMapsUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open maps.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final AppLocalizations l10n = context.l10n;
    final Event event = widget.event;

    // Set status bar style based on theme
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppTheme.getPrimaryColor(context),
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: isDarkMode
                      ? Brightness.dark
                      : Brightness.light,
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      _showShareSheet(context);
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      event.featuredImage != null
                          ? Image.network(
                              AppConfig.getImageUrl(event.featuredImage!),
                              fit: BoxFit.cover,
                            )
                          : Container(color: AppTheme.mint200),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Event Title and Category
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: <Widget>[
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.getPrimaryColor(context),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  event.summary ?? 'Event',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              // Attendees with avatars
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (event.confirmedBookingsCount > 0)
                                    SizedBox(
                                      width:
                                          (event.confirmedBookingsCount > 5
                                                  ? 5
                                                  : event
                                                        .confirmedBookingsCount) *
                                              28 -
                                          ((event.confirmedBookingsCount > 5
                                                      ? 5
                                                      : event
                                                            .confirmedBookingsCount) -
                                                  1) *
                                              8,
                                      height: 28,
                                      child: Stack(
                                        children: List.generate(
                                          event.confirmedBookingsCount > 5
                                              ? 5
                                              : event.confirmedBookingsCount,
                                          (index) => Positioned(
                                            left: index * 20.0,
                                            child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor:
                                                  AppTheme.getPrimaryColor(
                                                    context,
                                                  ),
                                              backgroundImage: AssetImage(
                                                'assets/img/profile/profile_${(index % 8) + 1}.jpg',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (event.confirmedBookingsCount > 0)
                                    const SizedBox(width: 8),
                                  Text(
                                    '${event.confirmedBookingsCount} going',
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : AppTheme.getTextColor(
                                            context,
                                          ).withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Title
                          Text(
                            event.title,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Organizer Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppTheme.getPrimaryColor(context),
                            backgroundImage: AssetImage(
                              'assets/img/profile/profile_1.jpg',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'EduEx Events',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Organizer',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
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
                    const SizedBox(height: 16),
                    // Date & Time Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getPrimaryColor(context),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      event.startDate != null
                                          ? _formatFullDate(event.startDate!)
                                          : 'TBD',
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${event.startTime ?? ''} (GMT +06:00)',
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(
                                          context,
                                        ).withValues(alpha: 0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Countdown Timer (Matching Web)
                    if (event.startDate != null &&
                        event.startDate!.isAfter(DateTime.now()))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _CountdownTimer(targetDate: event.startDate!),
                      ),
                    const SizedBox(height: 16),
                    // Event Information Section (Matching Web)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                constraints: BoxConstraints(
                                  maxHeight: _isEventInfoExpanded ? 1000 : 250,
                                ),
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  child: Stack(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Event Information',
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            _InfoRow(
                                              icon: Icons.calendar_today,
                                              label: 'Start Date',
                                              value: event.startDate != null
                                                  ? _formatDate(
                                                      event.startDate!,
                                                    )
                                                  : 'TBD',
                                            ),
                                            _InfoRow(
                                              icon: Icons.calendar_today,
                                              label: 'End Date',
                                              value: event.endDate != null
                                                  ? _formatDate(event.endDate!)
                                                  : (event.startDate != null
                                                        ? _formatDate(
                                                            event.startDate!,
                                                          )
                                                        : 'TBD'),
                                            ),
                                            _InfoRow(
                                              icon: Icons.access_time,
                                              label: 'Start Time',
                                              value: event.startTime ?? 'TBD',
                                            ),
                                            _InfoRow(
                                              icon: Icons.access_time_filled,
                                              label: 'End Time',
                                              value: event.endTime ?? 'TBD',
                                            ),
                                            _InfoRow(
                                              icon: Icons.confirmation_number,
                                              label: 'Ticket Price',
                                              value:
                                                  event.price == 0 ||
                                                      event.price == null
                                                  ? 'Free'
                                                  : settingsProvider
                                                        .formatPrice(
                                                          event.price,
                                                        ),
                                              valueColor:
                                                  AppTheme.getPrimaryColor(
                                                    context,
                                                  ),
                                            ),
                                            _InfoRow(
                                              icon: Icons.event_seat,
                                              label: 'Total Seat',
                                              value:
                                                  '${event.totalSeats ?? 'Unlimited'}',
                                            ),
                                            _InfoRow(
                                              icon: Icons.event_seat_outlined,
                                              label: 'Remaining Seats',
                                              value: event.totalSeats != null
                                                  ? '${event.totalSeats! - event.confirmedBookingsCount}'
                                                  : 'Unlimited',
                                            ),
                                            _InfoRow(
                                              icon: Icons.book_online,
                                              label: 'Bookings',
                                              value:
                                                  '${event.confirmedBookingsCount} total',
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!_isEventInfoExpanded)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          height: 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: <Color>[
                                                  AppTheme.getCardColor(
                                                    context,
                                                  ).withValues(alpha: 0),
                                                  AppTheme.getCardColor(
                                                    context,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEventInfoExpanded = !_isEventInfoExpanded;
                                });
                              },
                              child: Text(
                                _isEventInfoExpanded
                                    ? 'Show Less'
                                    : 'See All Info',
                                style: TextStyle(
                                  color: AppTheme.getPrimaryColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // What you'll experience Section
                    if (event.highlights != null &&
                        event.highlights!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "What you'll experience",
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: event.highlights!.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final highlight = event.highlights![index];
                                final String title = highlight is Map
                                    ? highlight['title'] ?? ''
                                    : highlight.toString();
                                final String? description = highlight is Map
                                    ? highlight['description']
                                    : null;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: AppTheme.getPrimaryColor(
                                            context,
                                          ),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              title,
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                height: 1.4,
                                              ),
                                            ),
                                            if (description != null &&
                                                description.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2,
                                                ),
                                                child: Text(
                                                  description,
                                                  style: TextStyle(
                                                    color:
                                                        AppTheme.getTextColor(
                                                          context,
                                                        ).withValues(
                                                          alpha: 0.6,
                                                        ),
                                                    fontSize: 13,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Location Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getPrimaryColor(context),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      event.locationDescription ??
                                          event.location ??
                                          'Online',
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.location ?? 'Online',
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(
                                          context,
                                        ).withValues(alpha: 0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: _openMaps,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'See Location on Maps',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getPrimaryColor(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // About Event Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.aboutThisEvent,
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppTheme.getTextColor(context),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isExpanded
                                ? event.description
                                : event.description.length > 150
                                ? '${event.description.substring(0, 150)}...'
                                : event.description,
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.8),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          if (event.description.length > 150)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isExpanded ? 'Read less' : 'Read more...',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppTheme.getPrimaryColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Event Speakers Section
                    if ((event.instructors != null &&
                            event.instructors!.isNotEmpty) ||
                        (event.speakers != null && event.speakers!.isNotEmpty))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Event Speakers',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getTextColor(context),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    (event.instructors?.length ?? 0) +
                                    (event.speakers?.length ?? 0),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  String? name;
                                  String? title;
                                  String? image;

                                  if (index <
                                      (event.instructors?.length ?? 0)) {
                                    final item = event.instructors![index];
                                    final instructor = Instructor.fromJson(
                                      item is Map<String, dynamic> ? item : {},
                                    );
                                    name = instructor.name;
                                    title = instructor.professionalTitle;
                                    image = instructor.image;
                                  } else {
                                    final speakerIndex =
                                        index -
                                        (event.instructors?.length ?? 0);
                                    final item = event.speakers![speakerIndex];
                                    if (item is Map<String, dynamic>) {
                                      name = item['name'];
                                      title = item['title'];
                                      image = item['image_path'];
                                    }
                                  }
                                  return Container(
                                    width: 140,
                                    decoration: BoxDecoration(
                                      color: AppTheme.getCardColor(context),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(16),
                                                ),
                                            child: image != null
                                                ? Image.network(
                                                    AppConfig.getImageUrl(
                                                      image,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Image.asset(
                                                          'assets/img/default-profile.png',
                                                          fit: BoxFit.cover,
                                                          width:
                                                              double.infinity,
                                                        ),
                                                  )
                                                : Image.asset(
                                                    'assets/img/default-profile.png',
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                name ?? 'Speaker',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AppTheme.getTextColor(
                                                    context,
                                                  ),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (title != null)
                                                Text(
                                                  title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        AppTheme.getTextColor(
                                                          context,
                                                        ).withValues(
                                                          alpha: 0.6,
                                                        ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Location Map Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.location,
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppTheme.getTextColor(context),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getPrimaryColor(context),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  event.locationDescription ??
                                      event.location ??
                                      'Online',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.getMint100(context),
                                width: 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _GoogleMapEmbed(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ],
          ),
          // Floating Button with Gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppTheme.getBackgroundColor(context).withValues(alpha: 0),
                    AppTheme.getBackgroundColor(context).withValues(alpha: 0.8),
                    AppTheme.getBackgroundColor(context),
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: widget.event.isBooked
                  ? ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const MyTicketBookingsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getPrimaryColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: AppTheme.getPrimaryColor(
                          context,
                        ).withValues(alpha: 0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.confirmation_number, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.alreadyBooked,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TicketBookingScreen(event: widget.event),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.getPrimaryColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: AppTheme.getPrimaryColor(
                          context,
                        ).withValues(alpha: 0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.confirmation_number, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            event.price == 0 || event.price == null
                                ? l10n.registerNow
                                : l10n.bookTicket,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMapEmbed extends StatefulWidget {
  @override
  State<_GoogleMapEmbed> createState() => _GoogleMapEmbedState();
}

class _GoogleMapEmbedState extends State<_GoogleMapEmbed> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final String mapUrl =
        'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d142087.1494985877!2d90.3372881818202!3d23.780818635514635!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3755b8b087026b81%3A0x8fa563bbdd5904c2!2sDhaka!5e1!3m2!1sen!2sbd!4v1763406695636!5m2!1sen!2sbd';

    final String htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body, html {
      width: 100%;
      height: 100%;
      overflow: hidden;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: 0;
    }
  </style>
</head>
<body>
  <iframe
    src="$mapUrl"
    width="100%"
    height="100%"
    style="border:0;"
    allowfullscreen=""
    loading="lazy"
    referrerpolicy="no-referrer-when-downgrade">
  </iframe>
</body>
</html>
''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? AppTheme.getTextColor(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer({required this.targetDate});
  final DateTime targetDate;

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    if (widget.targetDate.isAfter(now)) {
      setState(() {
        _timeLeft = widget.targetDate.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative || _timeLeft == Duration.zero) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _TimerUnit(
            value: _timeLeft.inDays.toString().padLeft(2, '0'),
            label: 'DAYS',
          ),
          _TimerUnit(
            value: (_timeLeft.inHours % 24).toString().padLeft(2, '0'),
            label: 'HOURS',
          ),
          _TimerUnit(
            value: (_timeLeft.inMinutes % 60).toString().padLeft(2, '0'),
            label: 'MINUTES',
          ),
          _TimerUnit(
            value: (_timeLeft.inSeconds % 60).toString().padLeft(2, '0'),
            label: 'SECONDS',
          ),
        ],
      ),
    );
  }
}

class _TimerUnit extends StatelessWidget {
  const _TimerUnit({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: AppTheme.getPrimaryColor(context),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
