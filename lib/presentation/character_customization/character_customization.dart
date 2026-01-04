import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/avatar_preview_widget.dart';
import './widgets/category_tabs_widget.dart';
import './widgets/customization_grid_widget.dart';
import './widgets/gem_balance_widget.dart';
import './widgets/purchase_confirmation_sheet.dart';

/// Character Customization Screen
///
/// Enables avatar personalization through intuitive mobile interface
/// Features:
/// - Live avatar preview with 3D-style rotation
/// - Category-based customization (Hair, Face, Clothing, Accessories)
/// - Unlockable items with clear status indicators
/// - Gem economy integration
/// - Achievement-based unlocks
/// - Random generation capability
class CharacterCustomization extends StatefulWidget {
  const CharacterCustomization({super.key});

  @override
  State<CharacterCustomization> createState() => _CharacterCustomizationState();
}

class _CharacterCustomizationState extends State<CharacterCustomization>
    with SingleTickerProviderStateMixin {
  int _currentBottomIndex = 3; // Character tab
  int _selectedCategoryIndex = 0;
  late TabController _categoryTabController;

  // Current avatar configuration
  Map<String, String> _currentAvatar = {
    'hair': 'hair_1',
    'face': 'face_1',
    'clothing': 'clothing_1',
    'accessories': 'accessories_none',
  };

  // Original avatar state for cancel functionality
  late Map<String, String> _originalAvatar;

  // User's gem balance
  int _gemBalance = 1250;

  // Avatar rotation angle
  double _rotationAngle = 0.0;

  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: 4, vsync: this);
    _categoryTabController.addListener(_onCategoryChanged);
    _originalAvatar = Map.from(_currentAvatar);
  }

  @override
  void dispose() {
    _categoryTabController.removeListener(_onCategoryChanged);
    _categoryTabController.dispose();
    super.dispose();
  }

  void _onCategoryChanged() {
    if (_categoryTabController.indexIsChanging) {
      setState(() {
        _selectedCategoryIndex = _categoryTabController.index;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentBottomIndex) return;

    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog(() {
        _navigateToTab(index);
      });
    } else {
      _navigateToTab(index);
    }
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

  void _onItemSelected(Map<String, dynamic> item) {
    HapticFeedback.selectionClick();

    if (item['locked'] == true) {
      _showUnlockRequirements(item);
      return;
    }

    if (item['cost'] != null && item['cost'] > 0) {
      _showPurchaseConfirmation(item);
      return;
    }

    _applyItem(item);
  }

  void _applyItem(Map<String, dynamic> item) {
    setState(() {
      final category = _getCategoryKey(_selectedCategoryIndex);
      _currentAvatar[category] = item['id'] as String;
      _hasUnsavedChanges = true;
    });
  }

  String _getCategoryKey(int index) {
    switch (index) {
      case 0:
        return 'hair';
      case 1:
        return 'face';
      case 2:
        return 'clothing';
      case 3:
        return 'accessories';
      default:
        return 'hair';
    }
  }

  void _showPurchaseConfirmation(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PurchaseConfirmationSheet(
        item: item,
        currentGemBalance: _gemBalance,
        onConfirm: () {
          Navigator.pop(context);
          _purchaseItem(item);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _purchaseItem(Map<String, dynamic> item) {
    final cost = item['cost'] as int;

    if (_gemBalance >= cost) {
      setState(() {
        _gemBalance -= cost;
        item['locked'] = false;
        item['owned'] = true;
        _applyItem(item);
      });

      HapticFeedback.mediumImpact();
      _showSuccessSnackBar('Item purchased successfully!');
    } else {
      _showErrorSnackBar('Insufficient gems');
    }
  }

  void _showUnlockRequirements(Map<String, dynamic> item) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unlock Requirements', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['name'] as String, style: theme.textTheme.titleMedium),
            SizedBox(height: 2.h),
            if (item['unlockRequirement'] != null)
              _buildRequirementRow(
                theme,
                'Requirement',
                item['unlockRequirement'] as String,
              ),
            if (item['progress'] != null)
              _buildRequirementRow(
                theme,
                'Progress',
                item['progress'] as String,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _randomizeAvatar() {
    HapticFeedback.mediumImpact();

    setState(() {
      // Get random owned items from each category
      final hairItems = _getOwnedItems(0);
      final faceItems = _getOwnedItems(1);
      final clothingItems = _getOwnedItems(2);
      final accessoryItems = _getOwnedItems(3);

      if (hairItems.isNotEmpty) {
        _currentAvatar['hair'] = (hairItems..shuffle()).first['id'] as String;
      }
      if (faceItems.isNotEmpty) {
        _currentAvatar['face'] = (faceItems..shuffle()).first['id'] as String;
      }
      if (clothingItems.isNotEmpty) {
        _currentAvatar['clothing'] =
            (clothingItems..shuffle()).first['id'] as String;
      }
      if (accessoryItems.isNotEmpty) {
        _currentAvatar['accessories'] =
            (accessoryItems..shuffle()).first['id'] as String;
      }

      _hasUnsavedChanges = true;
    });

    _showSuccessSnackBar('Random style applied!');
  }

  List<Map<String, dynamic>> _getOwnedItems(int categoryIndex) {
    final allItems = _getItemsForCategory(categoryIndex);
    return (allItems)
        .where((item) => (item as Map<String, dynamic>)['owned'] == true)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  void _saveChanges() {
    HapticFeedback.mediumImpact();

    setState(() {
      _originalAvatar = Map.from(_currentAvatar);
      _hasUnsavedChanges = false;
    });

    // Save to local storage (implementation depends on state management)
    _showSuccessSnackBar('Changes saved successfully!');
  }

  void _cancelChanges() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog(() {
        setState(() {
          _currentAvatar = Map.from(_originalAvatar);
          _hasUnsavedChanges = false;
        });
        Navigator.pop(context);
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showUnsavedChangesDialog(VoidCallback onConfirm) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes', style: theme.textTheme.titleLarge),
        content: Text(
          'You have unsaved changes. Do you want to discard them?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'Discard',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF44336),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<dynamic> _getItemsForCategory(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return _hairItems;
      case 1:
        return _faceItems;
      case 2:
        return _clothingItems;
      case 3:
        return _accessoryItems;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Character Customization',
        variant: CustomAppBarVariant.standard,
        onBackPressed: _cancelChanges,
        actions: [
          TextButton(
            onPressed: _hasUnsavedChanges ? _saveChanges : null,
            child: Text(
              'Save',
              style: theme.textTheme.labelLarge?.copyWith(
                color: _hasUnsavedChanges
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Gem balance display
          GemBalanceWidget(gemBalance: _gemBalance),

          // Avatar preview section (top half)
          Expanded(
            flex: 5,
            child: AvatarPreviewWidget(
              currentAvatar: _currentAvatar,
              rotationAngle: _rotationAngle,
              onRotationChanged: (angle) {
                setState(() {
                  _rotationAngle = angle;
                });
              },
            ),
          ),

          // Customization options section (bottom half)
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Category tabs
                  CategoryTabsWidget(
                    controller: _categoryTabController,
                    selectedIndex: _selectedCategoryIndex,
                  ),

                  // Customization grid
                  Expanded(
                    child: CustomizationGridWidget(
                      items: _getItemsForCategory(_selectedCategoryIndex),
                      currentSelection:
                          _currentAvatar[_getCategoryKey(
                            _selectedCategoryIndex,
                          )] ??
                          '',
                      onItemSelected: _onItemSelected,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _randomizeAvatar,
        icon: CustomIconWidget(
          iconName: 'shuffle',
          color: theme.colorScheme.onSecondary,
          size: 24,
        ),
        label: Text(
          'Random',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSecondary,
          ),
        ),
        backgroundColor: theme.colorScheme.secondary,
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  // Mock data for customization items
  final List<Map<String, dynamic>> _hairItems = [
    {
      'id': 'hair_1',
      'name': 'Classic Short',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1238e4249-1766960113340.png',
      'semanticLabel': 'Short brown hair hairstyle illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'hair_2',
      'name': 'Long Waves',
      'image': 'https://images.unsplash.com/photo-1493123544220-7dee63cf1faf',
      'semanticLabel': 'Long wavy hair hairstyle illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'hair_3',
      'name': 'Spiky Style',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_13193ee1a-1766960104532.png',
      'semanticLabel': 'Spiky anime-style hair illustration',
      'locked': false,
      'owned': false,
      'cost': 150,
    },
    {
      'id': 'hair_4',
      'name': 'Ponytail',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1d9f36911-1767439581378.png',
      'semanticLabel': 'High ponytail hairstyle illustration',
      'locked': true,
      'owned': false,
      'unlockRequirement': 'Complete BSIT Level 5',
      'progress': '3/5 levels completed',
    },
    {
      'id': 'hair_5',
      'name': 'Curly Afro',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_10a47b48d-1766547296378.png',
      'semanticLabel': 'Curly afro hairstyle illustration',
      'locked': false,
      'owned': false,
      'cost': 200,
    },
    {
      'id': 'hair_6',
      'name': 'Braided Crown',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_10486b921-1766774318676.png',
      'semanticLabel': 'Braided crown hairstyle illustration',
      'locked': true,
      'owned': false,
      'unlockRequirement': 'Earn "Scholar" achievement',
      'progress': '0/1 achievement',
    },
  ];

  final List<Map<String, dynamic>> _faceItems = [
    {
      'id': 'face_1',
      'name': 'Happy Smile',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1e3b243d7-1767439579720.png',
      'semanticLabel': 'Smiling face expression illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'face_2',
      'name': 'Determined',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_16b965965-1767439581729.png',
      'semanticLabel': 'Determined face expression illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'face_3',
      'name': 'Cool Shades',
      'image': 'https://images.unsplash.com/photo-1659228137391-4b5429c5d058',
      'semanticLabel': 'Face with sunglasses illustration',
      'locked': false,
      'owned': false,
      'cost': 100,
    },
    {
      'id': 'face_4',
      'name': 'Thinking',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1063abb7a-1767374574884.png',
      'semanticLabel': 'Thoughtful face expression illustration',
      'locked': true,
      'owned': false,
      'unlockRequirement': 'Answer 100 questions correctly',
      'progress': '67/100 questions',
    },
    {
      'id': 'face_5',
      'name': 'Excited',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_180f9fd52-1767439580193.png',
      'semanticLabel': 'Excited face expression illustration',
      'locked': false,
      'owned': false,
      'cost': 120,
    },
  ];

  final List<Map<String, dynamic>> _clothingItems = [
    {
      'id': 'clothing_1',
      'name': 'Casual T-Shirt',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1998bde91-1767118145060.png',
      'semanticLabel': 'Blue casual t-shirt illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'clothing_2',
      'name': 'School Uniform',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1f524a765-1765119606991.png',
      'semanticLabel': 'School uniform with tie illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'clothing_3',
      'name': 'Hoodie',
      'image': 'https://images.unsplash.com/photo-1671748962201-bd66ae9a2d7a',
      'semanticLabel': 'Gray hoodie sweatshirt illustration',
      'locked': false,
      'owned': false,
      'cost': 180,
    },
    {
      'id': 'clothing_4',
      'name': 'Lab Coat',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_162ffd031-1766505852774.png',
      'semanticLabel': 'White laboratory coat illustration',
      'locked': true,
      'owned': false,
      'unlockRequirement': 'Complete BSCS program',
      'progress': '0/15 levels',
    },
    {
      'id': 'clothing_5',
      'name': 'Sports Jersey',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1898fc3d9-1767439580311.png',
      'semanticLabel': 'Red sports jersey illustration',
      'locked': false,
      'owned': false,
      'cost': 200,
    },
    {
      'id': 'clothing_6',
      'name': 'Graduation Gown',
      'image': 'https://images.unsplash.com/photo-1724434586379-a3e0c926c15c',
      'semanticLabel': 'Black graduation gown with cap illustration',
      'locked': true,
      'owned': false,
      'unlockRequirement': 'Complete any program',
      'progress': '0/1 program',
    },
  ];

  final List<Map<String, dynamic>> _accessoryItems = [
    {
      'id': 'accessories_none',
      'name': 'None',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_178b829d2-1766826268229.png',
      'semanticLabel': 'No accessories placeholder illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'accessories_1',
      'name': 'Glasses',
      'image': 'https://images.unsplash.com/photo-1562835419-517ea4553487',
      'semanticLabel': 'Round eyeglasses illustration',
      'locked': false,
      'owned': true,
      'cost': null,
    },
    {
      'id': 'accessories_2',
      'name': 'Headphones',
      'image': 'https://images.unsplash.com/photo-1689357639029-f9397ac24b6a',
      'semanticLabel': 'Blue wireless headphones illustration',
      'locked': false,
      'owned': false,
      'cost': 150,
    },
    {
      'id': 'accessories_3',
      'name': 'Crown',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_113d07b82-1767439581622.png',
      'semanticLabel': 'Golden crown accessory illustration',
      'locked': true,
      'owned': false,
      'unlockRequirement': 'Reach top 10 on leaderboard',
      'progress': 'Current rank: 45',
    },
    {
      'id': 'accessories_4',
      'name': 'Backpack',
      'image': 'https://images.unsplash.com/photo-1561022346-ff04cdce08c0',
      'semanticLabel': 'Red school backpack illustration',
      'locked': false,
      'owned': false,
      'cost': 120,
    },
    {
      'id': 'accessories_5',
      'name': 'Medal',
      'image':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1b0fb37cc-1765448636132.png',
      'semanticLabel': 'Gold medal with ribbon illustration',
      'locked': true,
      'owned': false,
      'unlockRequirement': 'Earn 50 achievements',
      'progress': '23/50 achievements',
    },
  ];
}
