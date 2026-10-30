import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../config/config.dart';
import '../../theme/app_theme.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedFilter = 'upcoming';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await _eventService.fetchEvents(filter: _selectedFilter);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> eventsList = data['data'] ?? [];
        setState(() {
          _events = eventsList.map((e) => Event.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load events';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while fetching events';
        _isLoading = false;
      });
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _EventFilterSheet(
        initialTimeFilter: _selectedFilter,
        onApplyFilters: (String timeFilter) {
          setState(() {
            _selectedFilter = timeFilter;
          });
          _fetchEvents();
        },
      ),
    );
  }

  // Placeholder for local filtering if needed, but we use server-side filtering
  // List<Event> get _filteredEvents => _events;

  String _formatDate(DateTime? date) {
    if (date == null) return '';
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

  @override
  Widget build(BuildContext context) {
    // We already handle this in AppBar/SliverAppBar typically but for standard Scaffold:
    // final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Search Bar
            Container(
              color: AppTheme.getBackgroundColor(context),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: _SearchBar(onFilterTap: () => _showFilterSheet(context)),
            ),
            // Events List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : _events.isEmpty
                  ? _EmptyEventsState(filterType: _selectedFilter)
                  : RefreshIndicator(
                      onRefresh: _fetchEvents,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _events.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (BuildContext context, int index) {
                          final Event event = _events[index];
                          return _EventCard(
                            event: event,
                            formattedDate: _formatDate(event.startDate),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EventDetailScreen(event: event),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(
        currentTab: BottomNavTab.events,
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getTextColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextColor(context),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.formattedDate,
    required this.onTap,
  });

  final Event event;
  final String formattedDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Event Image
            Stack(
              children: <Widget>[
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: AppTheme.mint200,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: event.featuredImage != null
                        ? Image.network(
                            AppConfig.getImageUrl(event.featuredImage!),
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.calendar_today,
                            color: AppTheme.getPrimaryColor(context),
                            size: 40,
                          ),
                  ),
                ),
                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.summary ?? 'Event',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Booked Badge (Hide for now as we don't have isBooked in model yet)
                /* if (event.isBooked)
                   ... */
              ],
            ),
            // Event Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
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
                  const SizedBox(height: 16),
                  // Date & Time
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCalendar01,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.startTime ?? '',
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
                  const SizedBox(height: 12),
                  // Venue
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLocation01,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.locationDescription ??
                              event.location ??
                              'Online',
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Attendees & Price
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAiUser,
                            size: 20,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${event.confirmedBookingsCount} attendees',
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        event.price == 0.00 || event.price == null
                            ? 'Free'
                            : settingsProvider.formatPrice(event.price),
                        style: TextStyle(
                          color: event.price == 0.00 || event.price == null
                              ? Colors.green
                              : AppTheme.getTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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
  }
}

class _EmptyEventsState extends StatelessWidget {
  const _EmptyEventsState({required this.filterType});

  final String filterType;

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    switch (filterType) {
      case 'upcoming':
        title = 'No Upcoming Events';
        message = 'Check back later for new events';
        break;
      case 'past':
        title = 'No Past Events';
        message = 'You haven\'t attended any events yet';
        break;
      default:
        title = 'No Events';
        message = 'There are no events available at the moment';
    }

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
                  icon: HugeIcons.strokeRoundedCalendar01,
                  size: 60,
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.3),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onFilterTap});

  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return SizedBox(
      height: 48,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.getCardColor(context),
                hintText: l10n.search,
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
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      // Handle search button tap
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.all(6),
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
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
              ),
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedFilterHorizontal,
                  size: 20,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.getTextColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventFilterSheet extends StatefulWidget {
  const _EventFilterSheet({
    required this.initialTimeFilter,
    required this.onApplyFilters,
  });

  final String initialTimeFilter;
  final ValueChanged<String> onApplyFilters;

  @override
  State<_EventFilterSheet> createState() => _EventFilterSheetState();
}

class _EventFilterSheetState extends State<_EventFilterSheet> {
  late String _selectedTimeFilter;
  final Set<String> _selectedCategories = <String>{};
  final Set<String> _selectedPrices = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedTimeFilter = widget.initialTimeFilter;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Column(
            children: <Widget>[
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Filter Events',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedTimeFilter = widget.initialTimeFilter;
                          _selectedCategories.clear();
                          _selectedPrices.clear();
                        });
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    // Time Filter
                    Text(
                      'Time',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _FilterChipButton(
                            label: 'Upcoming',
                            isSelected: _selectedTimeFilter == 'upcoming',
                            onTap: () {
                              setState(() {
                                _selectedTimeFilter = 'upcoming';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterChipButton(
                            label: 'Past',
                            isSelected: _selectedTimeFilter == 'past',
                            onTap: () {
                              setState(() {
                                _selectedTimeFilter = 'past';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FilterChipButton(
                            label: 'All',
                            isSelected: _selectedTimeFilter == 'all',
                            onTap: () {
                              setState(() {
                                _selectedTimeFilter = 'all';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Category Filter
                    Text(
                      'Category',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          <String>[
                            'Technology',
                            'Design',
                            'Development',
                            'Business',
                            'Marketing',
                          ].map<Widget>((String category) {
                            final bool isSelected = _selectedCategories
                                .contains(category);
                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCategories.add(category);
                                  } else {
                                    _selectedCategories.remove(category);
                                  }
                                });
                              },
                              selectedColor: AppTheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              checkmarkColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.getTextColor(context),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.2),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Price Filter
                    Text(
                      'Price',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          <String>[
                            'Free',
                            'Paid',
                            'Under ${settingsProvider.formatPrice(50)}',
                            '${settingsProvider.formatPrice(50)} - ${settingsProvider.formatPrice(100)}',
                            'Over ${settingsProvider.formatPrice(100)}',
                          ].map<Widget>((String price) {
                            final bool isSelected = _selectedPrices.contains(
                              price,
                            );
                            return FilterChip(
                              label: Text(price),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedPrices.add(price);
                                  } else {
                                    _selectedPrices.remove(price);
                                  }
                                });
                              },
                              selectedColor: AppTheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              checkmarkColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.getTextColor(context),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.2),
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // Apply Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(_selectedTimeFilter);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Apply Filters',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
