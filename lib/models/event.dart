class Event {
  final int id;
  final String title;
  final String? slug;
  final String? summary;
  final String description;
  final String? locationDescription;
  final String? location;
  final String? contactPhone;
  final String? contactEmail;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final int? totalSeats;
  final double? price;
  final bool isPublished;
  final String? featuredImage;
  final int confirmedBookingsCount;
  final List<dynamic>? speakers;
  final List<dynamic>? highlights;
  final List<dynamic>? instructors;
  final bool isBooked;

  Event({
    required this.id,
    required this.title,
    this.slug,
    this.summary,
    required this.description,
    this.locationDescription,
    this.location,
    this.contactPhone,
    this.contactEmail,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.totalSeats,
    this.price,
    required this.isPublished,
    this.featuredImage,
    this.confirmedBookingsCount = 0,
    this.speakers,
    this.highlights,
    this.instructors,
    this.isBooked = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      summary: json['summary'],
      description: json['description'] ?? '',
      locationDescription: json['location_description'],
      location: json['location'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalSeats: json['total_seats'],
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      isPublished: json['is_published'] ?? false,
      featuredImage: json['featured_image'],
      confirmedBookingsCount: json['confirmed_bookings_count'] ?? 0,
      speakers: json['speakers'],
      highlights: json['highlights'],
      instructors: json['instructors'],
      isBooked: json['is_booked'] ?? false,
    );
  }
}
