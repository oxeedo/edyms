import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../l10n/app_localizations.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  final Set<String> _paymentMethods = {};
  final List<Payment> _payments = [];
  bool _isLoading = true;
  int _page = 1;
  bool _hasMore = true;
  String _selectedFilter = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadPayments(loadMore: true);
      }
    }
  }

  Future<void> _loadPayments({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoading) return;
      setState(() => _isLoading = true);
    } else {
      setState(() {
        _isLoading = true;
        _page = 1;
        _payments.clear();
        _paymentMethods.clear();
      });
    }

    try {
      final newPayments = await _paymentService.getMyPayments(page: _page);
      setState(() {
        if (newPayments.isEmpty) {
          _hasMore = false;
        } else {
          _payments.addAll(newPayments);
          _paymentMethods.addAll(
            newPayments.map((p) => p.paymentMethod).where((m) => m.isNotEmpty),
          );
          _page++;
        }
      });
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get _totalSpent {
    return _payments.fold<double>(
      0.0,
      (sum, payment) => sum + (double.tryParse(payment.amount) ?? 0.0),
    );
  }

  List<Payment> get _filteredPayments {
    if (_selectedFilter == 'All') {
      return _payments;
    } else {
      return _payments
          .where(
            (p) =>
                p.paymentMethod.toLowerCase() == _selectedFilter.toLowerCase(),
          )
          .toList();
    }
  }

  void _showPaymentDetails(BuildContext context, Payment payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentDetailSheet(payment: payment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Get unique, sorted filters starting with 'All'
    final List<String> filters = ['All', ..._paymentMethods.toList()..sort()];

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
                      context.l10n.paymentHistory,
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
                  children: filters.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: filter,
                        isSelected:
                            _selectedFilter.toLowerCase() ==
                            filter.toLowerCase(),
                        onTap: () => setState(() => _selectedFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Payment List
            Expanded(
              child: _isLoading && _payments.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : _filteredPayments.isEmpty
                  ? _EmptyState(
                      icon: Icons.payment,
                      message: _payments.isEmpty
                          ? context.l10n.noPayments
                          : 'No payments found for $_selectedFilter',
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadPayments(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount:
                            _filteredPayments.length + (_hasMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == _filteredPayments.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final payment = _filteredPayments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PaymentCard(
                              payment: payment,
                              onTap: () =>
                                  _showPaymentDetails(context, payment),
                            ),
                          );
                        },
                      ),
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

  final Payment payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                        payment.courseTitle,
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
                        DateFormat(
                          'MMM d, yyyy • h:mm a',
                        ).format(payment.createdAt),
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
                          // Assuming amount is string, parse it
                          settingsProvider.formatPrice(
                            double.tryParse(payment.amount) ?? 0.0,
                          ),
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
                        color: _getStatusColor(
                          payment.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        payment.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(payment.status),
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
                  payment.paymentMethod,
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (payment.transactionId != null)
                  Text(
                    payment.transactionId!,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

class _PaymentDetailSheet extends StatelessWidget {
  const _PaymentDetailSheet({required this.payment});

  final Payment payment;

  Future<void> _downloadReceipt(BuildContext context) async {
    if (payment.receiptUrl == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Downloading receipt...')));

    try {
      final fileName = 'receipt_${payment.id}.pdf';
      final service = PaymentService();
      final filePath = await service.downloadReceipt(payment.id, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Receipt downloaded successfully'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () {
                  OpenFilex.open(filePath);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to download receipt'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  dynamic _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case 'pending':
        return HugeIcons.strokeRoundedTime01;
      case 'failed':
        return HugeIcons.strokeRoundedCancel01;
      default:
        return HugeIcons.strokeRoundedHelpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(payment.status);
    final statusIcon = _getStatusIcon(payment.status);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: statusIcon,
                    size: 40,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 16),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) => Text(
                    settings.formatPrice(
                      double.tryParse(payment.amount) ?? 0.0,
                    ),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    payment.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppTheme.getCardColor(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).transactionDetails,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow(
                  context,
                  AppLocalizations.of(context).course,
                  payment.courseTitle,
                ),
                _buildDivider(context),
                _buildDetailRow(
                  context,
                  AppLocalizations.of(context).date,
                  DateFormat('MMM d, yyyy h:mm a').format(payment.createdAt),
                ),
                _buildDivider(context),
                _buildDetailRow(
                  context,
                  AppLocalizations.of(context).paymentMethod,
                  payment.paymentMethod.toUpperCase(),
                ),
                if (payment.transactionId != null) ...[
                  _buildDivider(context),
                  _buildDetailRow(
                    context,
                    'Transaction ID',
                    payment.transactionId!,
                  ),
                ],
              ],
            ),
          ),

          if (payment.isOffline && payment.receiptUrl != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadReceipt(context),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload01,
                  size: 20,
                  color: Colors.white,
                ),
                label: const Text('Download Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: AppTheme.getTextColor(context).withValues(alpha: 0.1),
        height: 1,
      ),
    );
  }
}
