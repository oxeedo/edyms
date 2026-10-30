import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _selectedFilter = 'all'; // all, creditCard, paypal, applePay

  // Hard-coded payment history data
  final List<Map<String, dynamic>> _allPayments = const <Map<String, dynamic>>[
    <String, dynamic>{
      'courseTitle': 'User Interface Design',
      'amount': 300.00,
      'date': 'December 15, 2024',
      'status': 'completed',
      'paymentMethod': 'Credit Card',
      'transactionId': 'TXN-2024-001234',
    },
    <String, dynamic>{
      'courseTitle': 'Complete Full Stack Development',
      'amount': 450.00,
      'date': 'November 28, 2024',
      'status': 'completed',
      'paymentMethod': 'PayPal',
      'transactionId': 'TXN-2024-001189',
    },
    <String, dynamic>{
      'courseTitle': 'Mobile App Development',
      'amount': 350.00,
      'date': 'November 10, 2024',
      'status': 'completed',
      'paymentMethod': 'Apple Pay',
      'transactionId': 'TXN-2024-001056',
    },
    <String, dynamic>{
      'courseTitle': 'Data Science Fundamentals',
      'amount': 400.00,
      'date': 'October 22, 2024',
      'status': 'completed',
      'paymentMethod': 'Credit Card',
      'transactionId': 'TXN-2024-000987',
    },
    <String, dynamic>{
      'courseTitle': 'Web Development Bootcamp',
      'amount': 500.00,
      'date': 'October 5, 2024',
      'status': 'completed',
      'paymentMethod': 'Credit Card',
      'transactionId': 'TXN-2024-000845',
    },
    <String, dynamic>{
      'courseTitle': 'UI/UX Design Mastery',
      'amount': 400.00,
      'date': 'September 18, 2024',
      'status': 'completed',
      'paymentMethod': 'PayPal',
      'transactionId': 'TXN-2024-000712',
    },
  ];

  List<Map<String, dynamic>> get _filteredPayments {
    if (_selectedFilter == 'all') {
      return _allPayments;
    } else if (_selectedFilter == 'creditCard') {
      return _allPayments
          .where((payment) => payment['paymentMethod'] == 'Credit Card')
          .toList();
    } else if (_selectedFilter == 'paypal') {
      return _allPayments
          .where((payment) => payment['paymentMethod'] == 'PayPal')
          .toList();
    } else {
      return _allPayments
          .where((payment) => payment['paymentMethod'] == 'Apple Pay')
          .toList();
    }
  }

  double get _totalSpent {
    return _allPayments.fold<double>(
      0.0,
      (sum, payment) => sum + (payment['amount'] as double),
    );
  }

  void _showTransactionSheet(
    BuildContext context,
    Map<String, dynamic> payment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) =>
          _TransactionDetailSheet(payment: payment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

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
                      context.l10n.payments,
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
            // Total Spent Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.l10n.totalSpent,
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settingsProvider.formatPrice(_totalSpent),
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.getMint100(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.payment,
                          size: 28,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
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
                      label: 'Credit Card',
                      isSelected: _selectedFilter == 'creditCard',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'creditCard';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'PayPal',
                      isSelected: _selectedFilter == 'paypal',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'paypal';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Apple Pay',
                      isSelected: _selectedFilter == 'applePay',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'applePay';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Payment List
            Expanded(
              child: _filteredPayments.isEmpty
                  ? _EmptyState(
                      icon: Icons.payment,
                      message: context.l10n.noPayments,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filteredPayments.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> payment =
                            _filteredPayments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PaymentCard(
                            payment: payment,
                            onTap: () =>
                                _showTransactionSheet(context, payment),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, this.onTap});

  final Map<String, dynamic> payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String courseTitle = payment['courseTitle'] as String;
    final double amount = payment['amount'] as double;
    final String date = payment['date'] as String;
    final String status = payment['status'] as String;
    final String paymentMethod = payment['paymentMethod'] as String;
    final String transactionId = payment['transactionId'] as String;

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
                        courseTitle,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Consumer<SettingsProvider>(
                      builder: (context, settingsProvider, child) {
                        return Text(
                          settingsProvider.formatPrice(amount),
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
            Row(
              children: <Widget>[
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCreditCard,
                  size: 16,
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  paymentMethod,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  transactionId,
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

class _TransactionDetailSheet extends StatelessWidget {
  const _TransactionDetailSheet({required this.payment});

  final Map<String, dynamic> payment;

  @override
  Widget build(BuildContext context) {
    final String courseTitle = payment['courseTitle'] as String;
    final double amount = payment['amount'] as double;
    final String date = payment['date'] as String;
    final String status = payment['status'] as String;
    final String paymentMethod = payment['paymentMethod'] as String;
    final String transactionId = payment['transactionId'] as String;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.l10n.transactionDetails,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Transaction Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  _DetailRow(label: context.l10n.course, value: courseTitle),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: context.l10n.totalPrice,
                    value: Provider.of<SettingsProvider>(
                      context,
                      listen: false,
                    ).formatPrice(amount),
                    valueStyle: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: context.l10n.date, value: date),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: context.l10n.paymentMethod,
                    value: paymentMethod,
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    label: 'Status',
                    value: status.toUpperCase(),
                    valueWidget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Transaction ID',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              transactionId,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Copy to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.copiedToClipboard),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.getMint100(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCopy01,
                            size: 16,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.valueWidget,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child:
              valueWidget ??
              Text(
                value,
                textAlign: TextAlign.right,
                style:
                    valueStyle ??
                    TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
        ),
      ],
    );
  }
}
