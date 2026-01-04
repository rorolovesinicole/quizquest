import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:fluttermoji/fluttermoji.dart';
import '../../../core/app_export.dart';

/// Avatar Preview Widget
///
/// Displays live avatar preview with 3D-style rotation capability
/// Features:
/// - Interactive swipe gestures for rotation
/// - Zoom capability for detailed inspection
/// - Smooth transition animations
/// - Current customization display
class AvatarPreviewWidget extends StatefulWidget {
  final Map<String, String> currentAvatar;
  final double rotationAngle;
  final ValueChanged<double> onRotationChanged;

  const AvatarPreviewWidget({
    super.key,
    required this.currentAvatar,
    required this.rotationAngle,
    required this.onRotationChanged,
  });

  @override
  State<AvatarPreviewWidget> createState() => _AvatarPreviewWidgetState();
}

class _AvatarPreviewWidgetState extends State<AvatarPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    setState(() {
      _isZoomed = !_isZoomed;
      _isZoomed ? _zoomController.forward() : _zoomController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF4A90E2), const Color(0xFF6B73FF)],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Avatar display
          Center(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                widget.onRotationChanged(
                  widget.rotationAngle + details.delta.dx * 0.01,
                );
              },
              onDoubleTap: _toggleZoom,
              child: AnimatedBuilder(
                animation: _zoomAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _zoomAnimation.value,
                    child: Transform.rotate(
                      angle: widget.rotationAngle,
                      child: _buildAvatarComposite(theme),
                    ),
                  );
                },
              ),
            ),
          ),

          // Zoom indicator
          if (_isZoomed)
            Positioned(
              top: 2.h,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'zoom_in',
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Zoomed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Rotation hint
          Positioned(
            bottom: 2.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'swipe',
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Swipe to rotate • Double tap to zoom',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarComposite(ThemeData theme) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Live Fluttermoji Avatar
            Center(
              child: FluttermojiCircleAvatar(
                radius: 30.w,
                backgroundColor: theme.colorScheme.surface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
