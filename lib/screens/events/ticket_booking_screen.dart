import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import '../../providers/settings_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'payment_screen.dart';
import '../../models/event.dart';
import '../../config/config.dart';

class TicketBookingScreen extends StatefulWidget {
  const TicketBookingScreen({super.key, required this.event});

  final Event event;

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  int _quantity = 1;
  String _selectedTicketType = 'Standard';
  List<String> get _availableTicketTypes {
    if (widget.event.price == null || widget.event.price == 0) {
      return <String>['Standard'];
    }
    return <String>['Standard', 'VIP', 'Premium'];
  }

  final Map<String, double> _ticketPrices = <String, double>{
    'Standard': 0.0,
    'VIP': 50.0,
    'Premium': 100.0,
  };

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure selected type is valid for this event
    if (!_availableTicketTypes.contains(_selectedTicketType)) {
      _selectedTicketType = _availableTicketTypes.first;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        final user = authProvider.user;
        if (user != null) {
          final nameParts = user.name.split(' ');
          _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
          _lastNameController.text = nameParts.length > 1
              ? nameParts.sublist(1).join(' ')
              : '';
          _emailController.text = user.email;
        }
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    final double basePrice = widget.event.price ?? 0.0;
    final double typePrice = _ticketPrices[_selectedTicketType] ?? 0.0;
    return (basePrice + typePrice) * _quantity;
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
          l10n.bookTicket,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Event Summary Card
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
                        Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: widget.event.featuredImage != null
                                  ? Image.network(
                                      AppConfig.getImageUrl(
                                        widget.event.featuredImage!,
                                      ),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.event.title,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: AppTheme.getTextColor(
                                          context,
                                        ).withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(
                                          widget.event.startDate ??
                                              DateTime.now(),
                                        ),
                                        style: TextStyle(
                                          color: AppTheme.getTextColor(
                                            context,
                                          ).withValues(alpha: 0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: AppTheme.getTextColor(
                                          context,
                                        ).withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.event.locationDescription ??
                                              widget.event.location ??
                                              'Online',
                                          style: TextStyle(
                                            color: AppTheme.getTextColor(
                                              context,
                                            ).withValues(alpha: 0.6),
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Ticket Type Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Ticket Type',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(_availableTicketTypes.length, (index) {
                          final String type = _availableTicketTypes[index];
                          final bool isSelected = _selectedTicketType == type;
                          final double typePrice = _ticketPrices[type] ?? 0.0;
                          final double totalTypePrice =
                              (widget.event.price ?? 0.0) + typePrice;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTicketType = type;
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
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.getPrimaryColor(context)
                                            : AppTheme.getTextColor(
                                                context,
                                              ).withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      color: isSelected
                                          ? AppTheme.getPrimaryColor(context)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          type,
                                          style: TextStyle(
                                            color: AppTheme.getTextColor(
                                              context,
                                            ),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (typePrice > 0) ...<Widget>[
                                          const SizedBox(height: 4),
                                          Text(
                                            '+ ${settingsProvider.formatPrice(typePrice)}',
                                            style: TextStyle(
                                              color: AppTheme.getTextColor(
                                                context,
                                              ).withValues(alpha: 0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    totalTypePrice == 0
                                        ? l10n.free
                                        : settingsProvider.formatPrice(
                                            totalTypePrice,
                                          ),
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : AppTheme.getPrimaryColor(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity Selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Quantity',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.getCardColor(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.getMint100(context),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Number of Tickets',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      if (_quantity > 1) {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _quantity > 1
                                            ? AppTheme.getPrimaryColor(
                                                context,
                                              ).withValues(alpha: 0.1)
                                            : AppTheme.getMint100(context),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        color: _quantity > 1
                                            ? (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : AppTheme.getPrimaryColor(
                                                      context,
                                                    ))
                                            : AppTheme.getTextColor(
                                                context,
                                              ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    _quantity.toString(),
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppTheme.getPrimaryColor(
                                          context,
                                        ).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : AppTheme.getPrimaryColor(context),
                                      ),
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
                  const SizedBox(height: 24),
                  // Price Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getMint100(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Subtotal',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _totalPrice == 0
                                    ? l10n.free
                                    : settingsProvider.formatPrice(_totalPrice),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Service Fee',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _totalPrice == 0
                                    ? l10n.free
                                    : settingsProvider.formatPrice(2.00),
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                                _totalPrice == 0
                                    ? l10n.free
                                    : settingsProvider.formatPrice(
                                        _totalPrice + 2.00,
                                      ),
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
                  ),
                  const SizedBox(height: 24),
                  // Attendee Information
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Attendee Information',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _buildAttendeeField(
                                controller: _firstNameController,
                                label: 'First Name',
                                hint: 'John',
                                validator: (String? value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildAttendeeField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                hint: 'Doe',
                                validator: (String? value) =>
                                    value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildAttendeeField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'john.doe@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (!value.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildAttendeeField(
                          controller: _phoneController,
                          label: 'Phone (Optional)',
                          hint: '+1234567890',
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
          // Continue Button with Gradient
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          event: widget.event,
                          ticketType: _selectedTicketType,
                          quantity: _quantity,
                          subtotal: _totalPrice,
                          serviceFee: _totalPrice == 0 ? 0.0 : 2.00,
                          total: _totalPrice + (_totalPrice == 0 ? 0.0 : 2.00),
                          attendeeData: {
                            'first_name': _firstNameController.text,
                            'last_name': _lastNameController.text,
                            'email': _emailController.text,
                            'phone': _phoneController.text,
                          },
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Continue to Payment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildAttendeeField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.getMint100(context)),
        ),
        filled: true,
        fillColor: AppTheme.getCardColor(context),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
