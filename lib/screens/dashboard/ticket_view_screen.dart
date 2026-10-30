import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/event_service.dart';

class TicketViewScreen extends StatefulWidget {
  const TicketViewScreen({required this.bookingId, super.key});

  final int bookingId;

  @override
  State<TicketViewScreen> createState() => _TicketViewScreenState();
}

class _TicketViewScreenState extends State<TicketViewScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _ticketData;
  String? _qrCodeDataUri;

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  Future<void> _fetchTicketDetails() async {
    try {
      final response = await EventService().getBookingDetails(widget.bookingId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ticketData = data['ticket'];
          _qrCodeDataUri = data['qr_code'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load ticket details';
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getPrimaryColor(context),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error != null || _ticketData == null) {
      return Scaffold(
        backgroundColor: AppTheme.getPrimaryColor(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? 'Unknown error',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchTicketDetails();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final ticket = _ticketData!;
    final String eventName = ticket['event_name'] as String;
    final String eventDate = ticket['event_date'] as String;
    final String eventTime = ticket['event_time'] as String;
    final String venue = ticket['venue'] as String;
    final String ticketType = ticket['ticket_type'] as String;
    final String bookingRef = ticket['booking_id'] as String;
    final String passengerName = ticket['passenger_name'] as String;
    final String passengerId = ticket['passenger_id'] as String;
    final String seatNumbers = ticket['seat_numbers'] as String;
    final int quantity = (ticket['quantity'] is int)
        ? ticket['quantity']
        : int.tryParse(ticket['quantity'].toString()) ?? 1;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Parse date and time for display
    final String displayDate = eventDate;
    // Format time to ensure proper AM/PM format (e.g., "10:00 AM" instead of "10:00am")
    final String displayTime = eventTime.replaceAllMapped(
      RegExp(r'(\d{1,2}):(\d{2})\s*(am|pm)', caseSensitive: false),
      (match) =>
          '${match.group(1)}:${match.group(2)} ${match.group(3)!.toUpperCase()}',
    );

    return Scaffold(
      backgroundColor: AppTheme.getPrimaryColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              color: AppTheme.getPrimaryColor(context),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.eTicket,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
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
            // E-Ticket Card
            Expanded(
              child: Stack(
                children: <Widget>[
                  // White Card with Ticket Cuts
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: ClipPath(
                      clipper: TicketClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppTheme.surfaceDark
                              : Colors.white,
                        ),
                        child: Column(
                          children: <Widget>[
                            // QR Code Section
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: <Widget>[
                                  // QR Code
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _qrCodeDataUri != null
                                          ? _buildQrCode(_qrCodeDataUri!)
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.qr_code,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildStatusBadge(
                                    context,
                                    ticket['status'] as String,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.l10n.scanQRCodeInstruction,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  // Dashed Divider
                                  CustomPaint(
                                    painter: DashedLinePainter(),
                                    child: const SizedBox(
                                      width: double.infinity,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Booking Details Section
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Operator and Booking ID
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppTheme.getPrimaryColor(
                                                            context,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: HugeIcon(
                                                        icon: HugeIcons
                                                            .strokeRoundedTicket01,
                                                        size: 24,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      eventName,
                                                      style: TextStyle(
                                                        color:
                                                            AppTheme.getTextColor(
                                                              context,
                                                            ),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                ticketType,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              bookingRef,
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              context.l10n.bookingId,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    // Journey Information
                                    Row(
                                      children: <Widget>[
                                        // Departure
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                venue,
                                                style: TextStyle(
                                                  color: AppTheme.getTextColor(
                                                    context,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                displayTime,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : AppTheme.getPrimaryColor(
                                                          context,
                                                        ),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                displayDate,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    // Divider
                                    Container(
                                      height: 1,
                                      color: isDarkMode
                                          ? Colors.grey[700]
                                          : Colors.grey[200],
                                    ),
                                    const SizedBox(height: 24),
                                    // Passenger Information
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              _PassengerInfoRow(
                                                label: context.l10n.passenger,
                                                value: passengerName,
                                              ),
                                              const SizedBox(height: 16),
                                              _PassengerInfoRow(
                                                label: context.l10n.idNumber,
                                                value: passengerId,
                                              ),
                                              const SizedBox(height: 16),
                                              _PassengerInfoRow(
                                                label:
                                                    context.l10n.passengerType,
                                                value:
                                                    '${context.l10n.adult} (${context.l10n.general})',
                                              ),
                                              const SizedBox(height: 16),
                                              _PassengerInfoRow(
                                                label: 'Seats Booked',
                                                value: '$quantity',
                                              ),
                                              if (seatNumbers.isNotEmpty) ...[
                                                const SizedBox(height: 16),
                                                _PassengerInfoRow(
                                                  label: context.l10n.seats,
                                                  value:
                                                      '${context.l10n.carriage} 1 / $seatNumbers',
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Wavy Bottom Border
                  Positioned(
                    bottom: 0,
                    left: 20,
                    right: 20,
                    child: CustomPaint(
                      painter: WavyBorderPainter(
                        color: AppTheme.getPrimaryColor(context),
                      ),
                      child: const SizedBox(height: 30, width: double.infinity),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCode(String dataUri) {
    // The data URI comes as "data:image/svg+xml;base64,..."
    // We need to decode it if it's base64, or use network/file if it was a URL.
    // In our case it is a data URI. flutter_svg supports SvgPicture.memory for bytes.

    if (dataUri.startsWith('data:image/svg+xml;base64,')) {
      final String base64String = dataUri.split(',').last;
      return SvgPicture.memory(base64Decode(base64String), fit: BoxFit.contain);
    }
    // Fallback if not SVG or unknown format (though backend sends SVG)
    return const Center(child: Icon(Icons.qr_code, size: 100));
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Confirmed';
        break;
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Pending';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Cancelled';
        break;
      case 'completed':
      case 'used':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Used';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PassengerInfoRow extends StatelessWidget {
  const _PassengerInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({this.isHorizontal = false});

  final bool isHorizontal;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    if (isHorizontal) {
      const double dashWidth = 5;
      const double dashSpace = 3;
      double startX = 0;

      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2),
          paint,
        );
        startX += dashWidth + dashSpace;
      }
    } else {
      const double dashHeight = 5;
      const double dashSpace = 3;
      double startY = 0;

      while (startY < size.height) {
        canvas.drawLine(
          Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashHeight),
          paint,
        );
        startY += dashHeight + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WavyBorderPainter extends CustomPainter {
  WavyBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(0, 0);

    const double waveLength = 20;
    const double waveHeight = 10;

    for (double x = 0; x < size.width; x += waveLength) {
      path.quadraticBezierTo(x + waveLength / 2, waveHeight, x + waveLength, 0);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    const double topNotchRadius = 12;
    const double sideNotchRadius = 12;

    // Start from top-left corner with notch
    path.moveTo(topNotchRadius, 0);

    // Top-left corner notch (semicircle cut INWARD - curves downward)
    path.arcToPoint(
      Offset(0, topNotchRadius),
      radius: const Radius.circular(topNotchRadius),
      clockwise: true, // Clockwise curves downward (inward for top-left)
      largeArc: false,
    );

    // Left edge - straight line down to side notch start
    path.lineTo(0, size.height / 2 - sideNotchRadius);

    // Left side notch (semicircle cut INWARD - curves to the right)
    path.arcToPoint(
      Offset(0, size.height / 2 + sideNotchRadius),
      radius: const Radius.circular(sideNotchRadius),
      clockwise: true, // Clockwise curves to the right (inward for left side)
      largeArc: false,
    );

    // Left edge continued - straight line to bottom
    path.lineTo(0, size.height);

    // Bottom edge - straight line (no rounding)
    path.lineTo(size.width, size.height);

    // Right edge - straight line up to side notch start
    path.lineTo(size.width, size.height / 2 + sideNotchRadius);

    // Right side notch (semicircle cut INWARD - curves to the left)
    path.arcToPoint(
      Offset(size.width, size.height / 2 - sideNotchRadius),
      radius: const Radius.circular(sideNotchRadius),
      clockwise: true, // Clockwise curves to the left (inward for right side)
      largeArc: false,
    );

    // Right edge continued - straight line to top notch start
    path.lineTo(size.width, topNotchRadius);

    // Top-right corner notch (semicircle cut INWARD - curves downward)
    path.arcToPoint(
      Offset(size.width - topNotchRadius, 0),
      radius: const Radius.circular(topNotchRadius),
      clockwise: true, // Clockwise curves downward (inward for top-right)
      largeArc: false,
    );

    // Top edge - straight line
    path.lineTo(topNotchRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
