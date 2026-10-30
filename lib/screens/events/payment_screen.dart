import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'booking_confirmation_screen.dart';
import '../../services/event_service.dart';
import 'dart:convert';
import '../../models/event.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.event,
    required this.ticketType,
    required this.quantity,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    required this.attendeeData,
  });

  final Event event;
  final String ticketType;
  final int quantity;
  final double subtotal;
  final double serviceFee;
  final double total;
  final Map<String, dynamic> attendeeData;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isLoading = false;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  Future<void> _bookEvent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await EventService().bookEvent(
        eventId: widget.event.id,
        data: {
          'first_name': widget.attendeeData['first_name'],
          'last_name': widget.attendeeData['last_name'],
          'email': widget.attendeeData['email'],
          'seats': widget.quantity,
          'phone': widget.attendeeData['phone'],
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          mounted) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final int bookingId = responseData['booking']['id'] as int;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              event: widget.event,
              ticketType: widget.ticketType,
              quantity: widget.quantity,
              total: widget.total,
              bookingId: bookingId,
            ),
          ),
        );
      } else if (mounted) {
        final Map<String, dynamic> errorData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final String message =
            (errorData['message'] as String?) ?? 'Failed to book event.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final List<Map<String, dynamic>> _paymentMethods = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
    },
    <String, dynamic>{
      'id': 'paypal',
      'name': 'PayPal',
      'icon': Icons.account_balance_wallet,
    },
    <String, dynamic>{'id': 'apple', 'name': 'Apple Pay', 'icon': Icons.apple},
    <String, dynamic>{
      'id': 'google',
      'name': 'Google Pay',
      'icon': Icons.account_balance,
    },
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getPrimaryColor(context),
        foregroundColor: Colors.white,
        title: Text(
          l10n.paymentMethod,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Order Summary
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.getMint100(context),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Order Summary',
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SummaryRow(label: 'Event', value: widget.event.title),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Ticket Type',
                        value: widget.ticketType,
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Quantity',
                        value: widget.quantity.toString(),
                      ),
                      const Divider(height: 24),
                      _SummaryRow(
                        label: 'Subtotal',
                        value: widget.subtotal == 0
                            ? l10n.free
                            : settingsProvider.formatPrice(widget.subtotal),
                      ),
                      const SizedBox(height: 8),
                      _SummaryRow(
                        label: 'Service Fee',
                        value: widget.serviceFee == 0
                            ? l10n.free
                            : settingsProvider.formatPrice(widget.serviceFee),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Total',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.total == 0
                                ? l10n.free
                                : settingsProvider.formatPrice(widget.total),
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppTheme.getPrimaryColor(context),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Payment Methods
                if (widget.total > 0) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Card Details',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_paymentMethods.length, (index) {
                          final Map<String, dynamic> method =
                              _paymentMethods[index];
                          final bool isSelected =
                              _selectedPaymentMethod == method['id'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = method['id'] as String;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.getPrimaryColor(
                                        context,
                                      ).withValues(alpha: 0.1)
                                    : AppTheme.getCardColor(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.getPrimaryColor(context)
                                      : AppTheme.getMint100(context),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    method['icon'] as IconData,
                                    color: isSelected
                                        ? AppTheme.getPrimaryColor(context)
                                        : AppTheme.getTextColor(context),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      method['name'] as String,
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.getPrimaryColor(context),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  // Card Details (if card selected)
                  if (_selectedPaymentMethod == 'card') ...<Widget>[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Card Details',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _cardHolderController,
                            decoration: InputDecoration(
                              labelText: 'Card Holder Name',
                              hintText: 'John Doe',
                              filled: true,
                              fillColor: AppTheme.getCardColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.getMint100(context),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.getMint100(context),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.getPrimaryColor(context),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _cardNumberController,
                            decoration: InputDecoration(
                              labelText: 'Card Number',
                              hintText: '1234 5678 9012 3456',
                              filled: true,
                              fillColor: AppTheme.getCardColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.getMint100(context),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.getMint100(context),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.getPrimaryColor(context),
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: _expiryController,
                                  decoration: InputDecoration(
                                    labelText: 'Expiry',
                                    hintText: 'MM/YY',
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getMint100(context),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getMint100(context),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(
                                          context,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _cvvController,
                                  decoration: InputDecoration(
                                    labelText: 'CVV',
                                    hintText: '123',
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getMint100(context),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getMint100(context),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(
                                          context,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
          // Pay Button with Gradient
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
              child: ElevatedButton(
                onPressed: _isLoading ? null : _bookEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.total == 0
                                ? 'Complete Registration'
                                : 'Pay Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.lock, size: 20),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  bool _isAmountValue(String value, SettingsProvider settingsProvider) {
    return value.contains(settingsProvider.currencySymbol) ||
        value == 'Free' ||
        value == 'free';
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: _isAmountValue(value, settingsProvider)
                ? (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.getTextColor(context))
                : AppTheme.getTextColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
