class Payment {
  final int id;
  final String amount;
  final String status;
  final String paymentMethod;
  final String? transactionId;
  final DateTime createdAt;
  final String courseTitle;
  final String? receiptUrl;
  final bool isOffline;

  Payment({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    required this.courseTitle,
    this.receiptUrl,
    required this.isOffline,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'].toString(),
      status: json['status'],
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      createdAt: DateTime.parse(json['created_at']),
      courseTitle: json['course_title'] ?? 'Unknown Course',
      receiptUrl: json['receipt_url'],
      isOffline: json['is_offline'] ?? false,
    );
  }
}
