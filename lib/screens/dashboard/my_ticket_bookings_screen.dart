import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event_booking.dart';
import '../../services/event_service.dart';
import 'ticket_view_screen.dart';

class MyTicketBookingsScreen extends StatefulWidget {
  const MyTicketBookingsScreen({super.key});

  @override
  State<MyTicketBookingsScreen> createState() => _MyTicketBookingsScreenState();
}

class _MyTicketBookingsScreenState extends State<MyTicketBookingsScreen> {
  String _selectedFilter = 'all'; // all, confirmed, pending, cancelled
  bool _isLoading = true;
  String? _error;
  List<EventBooking> _allTickets = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final response = await EventService().getMyBookings();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> bookingsJson = data['data'];
        setState(() {
          _allTickets = bookingsJson
              .map((json) => EventBooking.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load bookings';
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

  List<EventBooking> get _filteredTickets {
    if (_selectedFilter == 'all') {
      return _allTickets;
    }
    return _allTickets
        .where((ticket) => ticket.status == _selectedFilter)
        .toList();
  }

  int get _totalTickets {
    return _allTickets.length;
  }

  int get _confirmedTickets {
    return _allTickets.where((ticket) => ticket.status == 'confirmed').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                  Expanded(
                    child: Text(
                      context.l10n.myTicketBookings,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _fetchBookings();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _totalTickets.toString(),
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.totalTickets,
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _confirmedTickets.toString(),
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.confirmedTickets,
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _FilterChip(
                        label: context.l10n.all,
                        isSelected: _selectedFilter == 'all',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: context.l10n.confirmed,
                        isSelected: _selectedFilter == 'confirmed',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'confirmed';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: context.l10n.pending,
                        isSelected: _selectedFilter == 'pending',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'pending';
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: context.l10n.cancelled,
                        isSelected: _selectedFilter == 'cancelled',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'cancelled';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Ticket List
              Expanded(
                child: _filteredTickets.isEmpty
                    ? _EmptyState(
                        icon: HugeIcons.strokeRoundedTicket01,
                        message: context.l10n.noTicketBookings,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredTickets.length,
                        itemBuilder: (BuildContext context, int index) {
                          final EventBooking ticket = _filteredTickets[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TicketCard(
                              ticket: ticket,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TicketViewScreen(bookingId: ticket.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, this.onTap});

  final EventBooking ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    Color statusColor;
    String statusText;

    switch (ticket.status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = context.l10n.confirmed;
        break;
      case 'pending':
        statusColor = AppTheme.softOrange800;
        statusText = context.l10n.pending;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = context.l10n.cancelled;
        break;
      default:
        statusColor = AppTheme.getTextColor(context).withValues(alpha: 0.5);
        statusText = ticket.status;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ticket.eventTitle,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (ticket.startDateFormatted.isNotEmpty)
                        Row(
                          children: <Widget>[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar01,
                              size: 14,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ticket.startDateFormatted} • ${ticket.startTimeFormatted}',
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            if (ticket.venue != null) ...[
              Row(
                children: <Widget>[
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedLocation01,
                    size: 16,
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ticket.venue!,
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getMint100(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.totalPrice > 0
                        ? 'Standard'
                        : 'Free', // Or assume Standard for now
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${context.l10n.quantity}: ${ticket.seats}',
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  ticket.totalPrice == 0
                      ? context.l10n.free
                      : settingsProvider.formatPrice(ticket.totalPrice),
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  ticket.reference,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextColor(context),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final dynamic icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.getMint100(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: icon is IconData
                  ? Icon(
                      icon as IconData,
                      size: 40,
                      color: AppTheme.getPrimaryColor(context),
                    )
                  : HugeIcon(
                      icon: icon,
                      size: 40,
                      color: AppTheme.getPrimaryColor(context),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
