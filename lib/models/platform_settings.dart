class PlatformSettings {
  final Map<String, dynamic> platform;
  final Map<String, dynamic> branding;
  final Map<String, dynamic> contact;
  final Map<String, dynamic> withdrawals;
  final CurrencySettings currency;
  final List<PaymentMethod> paymentMethods;

  PlatformSettings({
    required this.platform,
    required this.branding,
    required this.contact,
    required this.withdrawals,
    required this.currency,
    required this.paymentMethods,
  });

  factory PlatformSettings.fromJson(Map<String, dynamic> json) {
    return PlatformSettings(
      platform: Map<String, dynamic>.from(json['platform'] ?? {}),
      branding: Map<String, dynamic>.from(json['branding'] ?? {}),
      contact: Map<String, dynamic>.from(json['contact'] ?? {}),
      withdrawals: Map<String, dynamic>.from(json['withdrawals'] ?? {}),
      currency: CurrencySettings.fromJson(json['currency'] ?? {}),
      paymentMethods: json['payment_methods'] != null
          ? (json['payment_methods'] as List)
                .map((p) => PaymentMethod.fromJson(p))
                .toList()
          : [],
    );
  }

  String get siteName => platform['site_name'] ?? 'EduEx';
  String get tagline => platform['tagline'] ?? '';
  String get supportEmail => contact['support_email'] ?? 'info@eduex.com';
  String get supportPhone => contact['support_phone'] ?? '';
}

class CurrencySettings {
  final String code;
  final String symbol;

  CurrencySettings({required this.code, required this.symbol});

  factory CurrencySettings.fromJson(Map<String, dynamic> json) {
    return CurrencySettings(
      code: json['code'] ?? 'USD',
      symbol: json['symbol'] ?? '\$',
    );
  }
}

class PaymentMethod {
  final String identifier;
  final String name;
  final String? description;
  final String type;
  final bool isEnabled;
  final String? instructions;

  PaymentMethod({
    required this.identifier,
    required this.name,
    this.description,
    required this.type,
    required this.isEnabled,
    this.instructions,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      identifier: json['identifier'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      type: json['type'] ?? 'online',
      isEnabled: json['is_enabled'] ?? false,
      instructions: json['instructions'],
    );
  }
}
