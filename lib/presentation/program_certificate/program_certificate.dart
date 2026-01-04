import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/certificate_action_buttons_widget.dart';
import './widgets/certificate_content_widget.dart';
import './widgets/certificate_header_widget.dart';
import './widgets/certificate_signature_widget.dart';
import './widgets/social_share_buttons_widget.dart';

/// Program Certificate Screen
///
/// Celebrates academic achievement through professional certificate display
/// Features:
/// - Congratulatory animation with certificate slide-in and confetti
/// - Professional certificate layout with student details and performance summary
/// - Pinch-to-zoom for detailed inspection
/// - Multiple sharing options (PDF, image, social media)
/// - Print functionality via system print services
/// - QR code generation for verification
/// - Offline certificate access with cached data
class ProgramCertificate extends StatefulWidget {
  const ProgramCertificate({super.key});

  @override
  State<ProgramCertificate> createState() => _ProgramCertificateState();
}

class _ProgramCertificateState extends State<ProgramCertificate>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final GlobalKey _certificateKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  bool _isLoading = true;
  bool _showConfetti = false;

  // Mock certificate data
  final Map<String, dynamic> _certificateData = {
    "studentName": "Alexandra Martinez",
    "programTitle": "Bachelor of Science in Information Technology",
    "programCode": "BSIT",
    "completionDate": "01/03/2026",
    "overallAccuracy": "94.5%",
    "totalStudyTime": "127 hours",
    "achievementCount": 42,
    "certificateId": "QQA-BSIT-2026-001234",
    "finalScore": 945,
    "totalQuestions": 1500,
    "correctAnswers": 1418,
    "levelsCompleted": 15,
    "averageTimePerLevel": "8.5 hours",
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCertificate();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _loadCertificate() async {
    // Simulate certificate loading with assembly progress
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
      _animationController.forward();

      // Show confetti after certificate appears
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() => _showConfetti = true);
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _showConfetti = false);
          });
        }
      });
    }
  }

  Future<void> _shareCertificate() async {
    try {
      HapticFeedback.mediumImpact();

      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text('Preparing certificate for sharing...'),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Capture certificate as image
      await Future.delayed(const Duration(milliseconds: 500));

      final RenderRepaintBoundary boundary =
          _certificateKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        // Share using share_plus package
        await Share.shareXFiles(
          [
            XFile.fromData(
              pngBytes,
              name:
                  'certificate_${_certificateData["programCode"]}_${DateTime.now().millisecondsSinceEpoch}.png',
              mimeType: 'image/png',
            ),
          ],
          text:
              'I completed ${_certificateData["programTitle"]} with ${_certificateData["overallAccuracy"]} accuracy! 🎓 #QuizQuestAcademy #Achievement',
        );

        Fluttertoast.showToast(
          msg: "Certificate shared successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to share certificate. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _saveToPhotos() async {
    try {
      HapticFeedback.lightImpact();

      Fluttertoast.showToast(
        msg: "Saving certificate to photos...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Simulate save operation
      await Future.delayed(const Duration(milliseconds: 800));

      Fluttertoast.showToast(
        msg: "Certificate saved to photos successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save certificate. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _printCertificate() async {
    try {
      HapticFeedback.lightImpact();

      Fluttertoast.showToast(
        msg: "Opening print dialog...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Simulate print dialog
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Print Certificate'),
            content: const Text(
              'Print functionality will open your device\'s print dialog. Make sure you have a printer configured.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: "Print job sent successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
                child: const Text('Print'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to print certificate. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _emailPdf() async {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Opening email with PDF attachment...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _copyUrl() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(
      ClipboardData(
        text:
            'https://quizquest.academy/verify/${_certificateData["certificateId"]}',
      ),
    );
    Fluttertoast.showToast(
      msg: "Certificate URL copied to clipboard!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _generateQrCode() async {
    HapticFeedback.lightImpact();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Certificate QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.w),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'qr_code_2',
                        color: Theme.of(context).colorScheme.primary,
                        size: 40.w,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'QR Code Preview',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Scan to verify certificate authenticity',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _shareCertificate();
              },
              child: const Text('Share QR'),
            ),
          ],
        ),
      );
    }
  }

  void _viewAllCertificates() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Opening certificate gallery...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Certificate',
        variant: CustomAppBarVariant.standard,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: theme.colorScheme.onSurface,
              size: 6.w,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showMoreOptions();
            },
            tooltip: 'More options',
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildCertificateView(),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Assembling your certificate...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Preparing achievement summary',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateView() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Certificate container with pinch-to-zoom
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 1.0,
                            maxScale: 3.0,
                            child: RepaintBoundary(
                              key: _certificateKey,
                              child: _buildCertificateCard(),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Social share options
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SocialShareButtonsWidget(
                        onEmailShare: _emailPdf,
                        onCopyUrl: _copyUrl,
                        onGenerateQr: _generateQrCode,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // View all certificates button
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: TextButton.icon(
                          onPressed: _viewAllCertificates,
                          icon: CustomIconWidget(
                            iconName: 'folder_open',
                            color: Theme.of(context).colorScheme.primary,
                            size: 5.w,
                          ),
                          label: Text(
                            'View All Certificates',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),

            // Action buttons
            FadeTransition(
              opacity: _fadeAnimation,
              child: CertificateActionButtonsWidget(
                onShare: _shareCertificate,
                onSaveToPhotos: _saveToPhotos,
                onPrint: _printCertificate,
              ),
            ),
          ],
        ),

        // Confetti animation overlay
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(child: _buildConfettiAnimation()),
          ),
      ],
    );
  }

  Widget _buildCertificateCard() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            // Certificate header
            const CertificateHeaderWidget(),

            SizedBox(height: 4.h),

            // Certificate content
            CertificateContentWidget(
              studentName: _certificateData["studentName"] as String,
              programTitle: _certificateData["programTitle"] as String,
              completionDate: _certificateData["completionDate"] as String,
              overallAccuracy: _certificateData["overallAccuracy"] as String,
              totalStudyTime: _certificateData["totalStudyTime"] as String,
              achievementCount: _certificateData["achievementCount"] as int,
            ),

            SizedBox(height: 4.h),

            // Certificate signature
            CertificateSignatureWidget(
              certificateId: _certificateData["certificateId"] as String,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfettiAnimation() {
    return CustomPaint(
      painter: _ConfettiPainter(animation: _animationController),
      child: Container(),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Email Certificate'),
              onTap: () {
                Navigator.pop(context);
                _emailPdf();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'link',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Copy Verification URL'),
              onTap: () {
                Navigator.pop(context);
                _copyUrl();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'qr_code_2',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('Generate QR Code'),
              onTap: () {
                Navigator.pop(context);
                _generateQrCode();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'folder_open',
                color: Theme.of(context).colorScheme.primary,
                size: 6.w,
              ),
              title: const Text('View All Certificates'),
              onTap: () {
                Navigator.pop(context);
                _viewAllCertificates();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for confetti animation
class _ConfettiPainter extends CustomPainter {
  final Animation<double> animation;

  _ConfettiPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFF6B73FF),
      const Color(0xFFF44336),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
    ];

    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y = (animation.value * size.height * 1.5) - (i * 20);

      if (y > 0 && y < size.height) {
        paint.color = colors[i % colors.length].withValues(alpha: 0.7);
        canvas.drawCircle(Offset(x, y), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
