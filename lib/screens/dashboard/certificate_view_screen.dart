import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/certificate.dart';
import '../../providers/auth_provider.dart';

class CertificateViewScreen extends StatefulWidget {
  const CertificateViewScreen({required this.certificate, super.key});

  final Certificate certificate;

  @override
  State<CertificateViewScreen> createState() => _CertificateViewScreenState();
}

class _CertificateViewScreenState extends State<CertificateViewScreen> {
  late Certificate certificate;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    certificate = widget.certificate;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final String title = certificate.title;
    final String issuedDate = certificate.issuedDate;
    final String certificateId = certificate.certificateId;
    final String? courseImage = certificate.courseImage;

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
                      context.l10n.certificate,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for centering
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    // Certificate Preview Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: <Widget>[
                          // Certificate Image/Preview
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppTheme.mint200,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                if (courseImage != null)
                                  Image.network(
                                    courseImage,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/img/courses/course1.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                  )
                                else
                                  Image.asset(
                                    'assets/img/courses/course1.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        AppTheme.primary.withValues(alpha: 0.8),
                                        AppTheme.primary.withValues(alpha: 0.9),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedCertificate01,
                                          size: 64,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          context.l10n.certificateOfCompletion,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Certificate Details
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.thisCertificateAwarded,
                            textAlign: TextAlign.center,
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
                            user?.name ?? 'Student',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 24),
                          // Info Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.l10n.issuedDate,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    issuedDate,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 60,
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.1),
                              ),
                              Column(
                                children: <Widget>[
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedCertificate01,
                                    size: 20,
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.l10n.certificateId,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    certificateId,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Verification Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.getMint100(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: HugeIcon(
                                    icon: HugeIcons
                                        .strokeRoundedCheckmarkCircle02,
                                    size: 20,
                                    color: AppTheme.getPrimaryColor(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      context.l10n.verifiedCertificate,
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context
                                          .l10n
                                          .certificateVerificationDescription,
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
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.getSoftGray150(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    certificateId,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Copy to clipboard
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.copiedToClipboard,
                                        ),
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        _downloadCertificate(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (_isDownloading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedDownload01,
                                size: 20,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _isDownloading
                                  ? 'Downloading...'
                                  : context.l10n.download,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadCertificate(BuildContext context) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Request storage permission on Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to download'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isDownloading = false;
          });
          return;
        }
      }

      final response = await http.get(Uri.parse(certificate.downloadUrl));

      if (response.statusCode == 200) {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          // Fallback if direct path doesn't exist (some devices)
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          // Clean filename
          final safeTitle = certificate.title.replaceAll(
            RegExp(r'[^\w\s]+'),
            '',
          );
          final fileName =
              'certificate_${safeTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final file = File('${directory.path}/$fileName');

          await file.writeAsBytes(response.bodyBytes);

          if (!mounted) return;
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Certificate downloaded to ${file.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () {
                  // Open the file
                  final uri = Uri.file(file.path);
                  launchUrl(uri);
                },
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to download certificate');
      }
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }
}
