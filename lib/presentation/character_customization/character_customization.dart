import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttermoji/fluttermoji.dart';

import '../../core/app_export.dart';
import '../../services/game_state_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/avatar_preview_widget.dart';
import './widgets/gem_balance_widget.dart';
import './widgets/purchase_confirmation_sheet.dart';

/// Character Customization Screen
///
/// Enables avatar personalization using Fluttermoji
class CharacterCustomization extends StatefulWidget {
  const CharacterCustomization({super.key});

  @override
  State<CharacterCustomization> createState() => _CharacterCustomizationState();
}

class _CharacterCustomizationState extends State<CharacterCustomization>
    with SingleTickerProviderStateMixin {
  final GameStateService _gameStateService = GameStateService();
  final TextEditingController _nameController = TextEditingController();

  int _currentBottomIndex = 3; // Character tab
  int _gemBalance = 0;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!_gameStateService.isInitialized) {
      await _gameStateService.initialize();
    }

    setState(() {
      _gemBalance = _gameStateService.totalGems;
      _nameController.text = _gameStateService.playerName;
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentBottomIndex) return;
    _navigateToTab(index);
  }

  void _navigateToTab(int index) {
    HapticFeedback.lightImpact();

    final routes = [
      AppRoutes.gameWorldMap,
      AppRoutes.progressAnalytics,
      AppRoutes.achievementGallery,
      AppRoutes.characterCustomization,
    ];

    if (index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  void _saveChanges() async {
    HapticFeedback.mediumImpact();

    // Save Name
    if (_nameController.text.isNotEmpty) {
      await _gameStateService.setPlayerName(_nameController.text.trim());
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Avatar and Name updated!"),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openStore() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
          ),
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Premium Presets",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: ListView(
                  children: [
                    _buildStoreItem(
                      "Wizard Set",
                      "Mystical hat and robe",
                      50,
                      'preset_wizard',
                    ),
                    _buildStoreItem(
                      "Cyberpunk Set",
                      "Futuristic neon gear",
                      75,
                      'preset_cyber',
                    ),
                    _buildStoreItem(
                      "Royal Set",
                      "Crown and velvet cape",
                      100,
                      'preset_royal',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreItem(String name, String desc, int cost, String id) {
    final isOwned = _gameStateService.isItemOwned(id);
    final canAfford = _gemBalance >= cost;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3.w),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.stars,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(desc, style: Theme.of(context).textTheme.bodySmall),
        trailing: isOwned
            ? Icon(Icons.check_circle, color: Colors.green)
            : ElevatedButton(
                onPressed: canAfford
                    ? () => _purchasePreset(name, cost, id)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text("$cost Gems"),
              ),
      ),
    );
  }

  Future<void> _purchasePreset(String name, int cost, String id) async {
    // Show confirmation
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PurchaseConfirmationSheet(
        itemName: name,
        itemDescription: "Unlock the $name preset!",
        gemCost: cost,
        currentGemBalance: _gemBalance,
        onConfirm: () async {
          final success = await _gameStateService.purchaseItem(id, cost);
          Navigator.pop(context); // Close sheet
          if (success) {
            setState(() {
              _gemBalance = _gameStateService.totalGems;
            });
            // Simulate Applying Preset
            if (mounted) {
              Navigator.pop(context); // Close store
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$name Unlocked & Applied!"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Not enough gems!")));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: 'Character Customization',
        variant: CustomAppBarVariant.standard,
        onBackPressed: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: _openStore,
            tooltip: "Premium Store",
          ),
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate available height excluding app bar and bottom nav
          final appBarHeight =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          final bottomNavHeight = 64 + MediaQuery.of(context).padding.bottom;
          final availableHeight =
              MediaQuery.of(context).size.height -
              appBarHeight -
              bottomNavHeight;

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight,
                maxHeight: availableHeight,
              ),
              child: Column(
                children: [
                  // Gem Balance Widget
                  GemBalanceWidget(gemBalance: _gemBalance),

                  const SizedBox(height: 8),

                  // Name Input - Fixed size
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                      decoration: InputDecoration(
                        hintText: "Enter Name",
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        prefixIcon: Icon(
                          Icons.edit,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),

                  // Avatar Preview - Flexible with constraints
                  Flexible(
                    flex: 3,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.25,
                        minHeight: 120,
                      ),
                      child: AvatarPreviewWidget(
                        currentAvatar: {},
                        rotationAngle: _rotationAngle,
                        onRotationChanged: (angle) {
                          setState(() {
                            _rotationAngle = angle;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Customization options section - Takes remaining space
                  Flexible(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: availableHeight * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4.w),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(4.w),
                        ),
                        child: FluttermojiCustomizer(
                          scaffoldHeight: availableHeight * 0.5,
                          autosave: true,
                          theme: FluttermojiThemeData(
                            boxDecoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                            ),
                            primaryBgColor: theme.colorScheme.surface,
                            secondaryBgColor:
                                theme.colorScheme.surfaceContainerHighest,
                            labelTextStyle: theme.textTheme.labelMedium,
                            selectedIconColor: theme.colorScheme.primary,
                            unselectedIconColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            iconColor: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
