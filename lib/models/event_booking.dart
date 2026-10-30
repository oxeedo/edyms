class EventBooking {
  final int id;
  final String eventTitle;
  final String? eventSlug;
  final bool hasEvent;
  final DateTime? bookedAt;
  final String bookedAtFormatted;
  final DateTime? startDate;
  final String? startTime;
  final String startDateFormatted;
  final String startTimeFormatted;
  final String? venue;
  final int seats;
  final String status;
  final String reference;
  final double totalPrice;

  EventBooking({
    required this.id,
    required this.eventTitle,
    this.eventSlug,
    required this.hasEvent,
    this.bookedAt,
    required this.bookedAtFormatted,
    this.startDate,
    this.startTime,
    required this.startDateFormatted,
    required this.startTimeFormatted,
    this.venue,
    required this.seats,
    required this.status,
    required this.reference,
    required this.totalPrice,
  });

  factory EventBooking.fromJson(Map<String, dynamic> json) {
    return EventBooking(
      id: json['id'] as int,
      eventTitle: json['event_title'] as String,
      eventSlug: json['event_slug'] as String?,
      hasEvent: json['has_event'] as bool,
      bookedAt: json['booked_at'] != null
          ? DateTime.parse(json['booked_at'])
          : null,
      bookedAtFormatted: json['booked_at_formatted'] as String,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      startTime: json['start_time'] as String?,
      startDateFormatted: json['start_date_formatted'] as String,
      startTimeFormatted: json['start_time_formatted'] as String,
      venue: json['venue'] as String?,
      seats: json['seats'] as int,
      status: json['status'] as String,
      reference: json['reference'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }
}
