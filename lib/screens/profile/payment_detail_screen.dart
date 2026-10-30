import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../theme/app_theme.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';

class PaymentDetailScreen extends StatelessWidget {
  final Payment payment;

  const PaymentDetailScreen({super.key, required this.payment});

  Future<void> _downloadReceipt(BuildContext context) async {
    if (payment.receiptUrl == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Downloading receipt...')));

    try {
      final fileName = 'receipt_${payment.id}.pdf';
      final service = PaymentService();
      final filePath = await service.downloadReceipt(payment.id, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (filePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Receipt downloaded successfully'),
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
          // Optional: Auto open
          // OpenFilex.open(filePath);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Payment Details',
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 24,
            color: AppTheme.getTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusHeader(context),
            SizedBox(height: 24),
            _buildDetailCard(context),
            if (payment.isOffline && payment.receiptUrl != null) ...[
              SizedBox(height: 24),
              _buildDownloadButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    Color statusColor;
    dynamic statusIcon;

    switch (payment.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = HugeIcons.strokeRoundedCheckmarkCircle02;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = HugeIcons.strokeRoundedTime01;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = HugeIcons.strokeRoundedCancel01;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = HugeIcons.strokeRoundedHelpCircle;
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: statusIcon, size: 40, color: statusColor),
          ),
          SizedBox(height: 16),
          Text(
            '\$${payment.amount}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              payment.status.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 24),
          _buildDetailRow(context, 'Course', payment.courseTitle),
          _buildDivider(context),
          _buildDetailRow(
            context,
            'Date',
            DateFormat('MMM d, yyyy h:mm a').format(payment.createdAt),
          ),
          _buildDivider(context),
          _buildDetailRow(
            context,
            'Payment Method',
            payment.paymentMethod.toUpperCase(),
          ),
          if (payment.transactionId != null) ...[
            _buildDivider(context),
            _buildDetailRow(context, 'Transaction ID', payment.transactionId!),
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

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _downloadReceipt(context),
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedDownload01,
          size: 20,
          color: Colors.white,
        ),
        label: Text('Download Receipt'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.getPrimaryColor(context),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
