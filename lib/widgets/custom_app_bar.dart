import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types for different contexts
enum CustomAppBarVariant {
  /// Standard app bar with title and actions
  standard,

  /// Centered title with back button
  centered,

  /// Large title for main screens
  large,

  /// Transparent overlay for immersive content
  transparent,

  /// Contextual app bar that adapts based on scroll
  contextual,
}

/// Custom app bar optimized for educational RPG gaming
///
/// Features:
/// - Multiple variants for different screen contexts
/// - Smooth transitions and animations
/// - Platform-adaptive styling
/// - Contextual actions based on game state
/// - Accessibility support
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: CustomAppBar(
///     title: 'World Map',
///     variant: CustomAppBarVariant.standard,
///     actions: [
///       IconButton(
///         icon: Icon(Icons.settings),
///         onPressed: () {},
///       ),
///     ],
///   ),
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a custom app bar
  ///
  /// [title] - Title text or widget
  /// [variant] - Visual variant of the app bar
  /// [leading] - Widget to display before the title (usually back button)
  /// [actions] - List of action widgets to display after the title
  /// [showBackButton] - Whether to show back button (default: auto-detect)
  /// [onBackPressed] - Custom back button callback
  /// [backgroundColor] - Custom background color
  /// [foregroundColor] - Custom foreground color for text and icons
  /// [elevation] - Shadow elevation (default: 0 for flat design)
  /// [centerTitle] - Whether to center the title
  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.showBackButton,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle,
  });

  final dynamic title; // String or Widget
  final CustomAppBarVariant variant;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool? centerTitle;

  @override
  Size get preferredSize {
    switch (variant) {
      case CustomAppBarVariant.large:
        return const Size.fromHeight(96);
      case CustomAppBarVariant.contextual:
        return const Size.fromHeight(72);
      default:
        return const Size.fromHeight(56);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        backgroundColor ??
        (variant == CustomAppBarVariant.transparent
            ? Colors.transparent
            : appBarTheme.backgroundColor ?? colorScheme.surface);

    final effectiveForegroundColor =
        foregroundColor ?? appBarTheme.foregroundColor ?? colorScheme.onSurface;

    final effectiveElevation =
        elevation ??
        (variant == CustomAppBarVariant.transparent
            ? 0
            : appBarTheme.elevation ?? 0);

    final shouldCenterTitle =
        centerTitle ??
        (variant == CustomAppBarVariant.centered ||
            variant == CustomAppBarVariant.large);

    final canPop = Navigator.canPop(context);
    final shouldShowBackButton = showBackButton ?? canPop;

    switch (variant) {
      case CustomAppBarVariant.large:
        return _buildLargeAppBar(
          context,
          effectiveBackgroundColor,
          effectiveForegroundColor,
          effectiveElevation,
          shouldShowBackButton,
        );

      case CustomAppBarVariant.transparent:
        return _buildTransparentAppBar(
          context,
          effectiveForegroundColor,
          shouldShowBackButton,
        );

      case CustomAppBarVariant.contextual:
        return _buildContextualAppBar(
          context,
          effectiveBackgroundColor,
          effectiveForegroundColor,
          effectiveElevation,
          shouldShowBackButton,
        );

      default:
        return _buildStandardAppBar(
          context,
          effectiveBackgroundColor,
          effectiveForegroundColor,
          effectiveElevation,
          shouldCenterTitle,
          shouldShowBackButton,
        );
    }
  }

  Widget _buildStandardAppBar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    double elevation,
    bool centerTitle,
    bool showBack,
  ) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: _buildLeading(context, showBack, foregroundColor),
      title: _buildTitle(context, foregroundColor),
      actions: _buildActions(context),
      systemOverlayStyle: _getSystemOverlayStyle(context, backgroundColor),
    );
  }

  Widget _buildLargeAppBar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    double elevation,
    bool showBack,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with back button and actions
              Row(
                children: [
                  if (showBack)
                    _buildLeading(context, showBack, foregroundColor) ??
                        const SizedBox.shrink(),
                  const Spacer(),
                  ..._buildActions(context) ?? [],
                ],
              ),

              const SizedBox(height: 8),

              // Large title
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: DefaultTextStyle(
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                    child: title is String
                        ? Text(title as String)
                        : title as Widget,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransparentAppBar(
    BuildContext context,
    Color foregroundColor,
    bool showBack,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      elevation: 0,
      leading: _buildLeading(context, showBack, foregroundColor),
      title: _buildTitle(context, foregroundColor),
      actions: _buildActions(context),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildContextualAppBar(
    BuildContext context,
    Color backgroundColor,
    Color foregroundColor,
    double elevation,
    bool showBack,
  ) {
    final theme = Theme.of(context);

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (showBack)
                _buildLeading(context, showBack, foregroundColor) ??
                    const SizedBox.shrink(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                        child: title is String
                            ? Text(title as String)
                            : title as Widget,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Level 5 • 250 XP',
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: foregroundColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ..._buildActions(context) ?? [],
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(
    BuildContext context,
    bool showBack,
    Color foregroundColor,
  ) {
    if (leading != null) return leading;

    if (!showBack) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: foregroundColor,
      onPressed: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
      tooltip: 'Back',
    );
  }

  Widget _buildTitle(BuildContext context, Color foregroundColor) {
    final theme = Theme.of(context);

    if (title == null) return const SizedBox.shrink();

    if (title is String) {
      return Text(
        title as String,
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          color: foregroundColor,
        ),
      );
    }

    return DefaultTextStyle(
      style: theme.appBarTheme.titleTextStyle!.copyWith(color: foregroundColor),
      child: title as Widget,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return null;

    return actions!.map((action) {
      return Padding(padding: const EdgeInsets.only(left: 8), child: action);
    }).toList();
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(
    BuildContext context,
    Color backgroundColor,
  ) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);

    return brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }
}

/// Sliver version of CustomAppBar for use with CustomScrollView
class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.showBackButton,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.expandedHeight,
    this.pinned = true,
    this.floating = false,
    this.flexibleSpace,
  });

  final dynamic title;
  final CustomAppBarVariant variant;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? expandedHeight;
  final bool pinned;
  final bool floating;
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        backgroundColor ?? appBarTheme.backgroundColor ?? colorScheme.surface;

    final effectiveForegroundColor =
        foregroundColor ?? appBarTheme.foregroundColor ?? colorScheme.onSurface;

    final canPop = Navigator.canPop(context);
    final shouldShowBackButton = showBackButton ?? canPop;

    return SliverAppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      expandedHeight:
          expandedHeight ?? (variant == CustomAppBarVariant.large ? 120 : null),
      pinned: pinned,
      floating: floating,
      leading: _buildLeading(
        context,
        shouldShowBackButton,
        effectiveForegroundColor,
      ),
      title: _buildTitle(context, effectiveForegroundColor),
      actions: actions,
      flexibleSpace: flexibleSpace,
      systemOverlayStyle: _getSystemOverlayStyle(
        context,
        effectiveBackgroundColor,
      ),
    );
  }

  Widget? _buildLeading(
    BuildContext context,
    bool showBack,
    Color foregroundColor,
  ) {
    if (leading != null) return leading;

    if (!showBack) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      color: foregroundColor,
      onPressed: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
      tooltip: 'Back',
    );
  }

  Widget? _buildTitle(BuildContext context, Color foregroundColor) {
    if (title == null) return null;

    final theme = Theme.of(context);

    if (title is String) {
      return Text(
        title as String,
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          color: foregroundColor,
        ),
      );
    }

    return DefaultTextStyle(
      style: theme.appBarTheme.titleTextStyle!.copyWith(color: foregroundColor),
      child: title as Widget,
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(
    BuildContext context,
    Color backgroundColor,
  ) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);

    return brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }
}
