// lib/screens/mess/mess_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/mock_data_service.dart';
import '../../theme.dart';

class MessScreen extends ConsumerStatefulWidget {
  const MessScreen({super.key});

  @override
  ConsumerState<MessScreen> createState() => _MessScreenState();
}

class _MessScreenState extends ConsumerState<MessScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _messData;
  late TabController _tabController;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late int _selectedDayIndex;

  // Track expanded categories
  final Map<String, bool> _expandedCategories = {
    'Breakfast': false,
    'Lunch': false,
    'Dinner': false,
    'Refreshment': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set current day and expand current meal category
    _selectedDayIndex = DateTime.now().weekday - 1;
    _expandCurrentMealCategory();

    _loadData();
  }

  void _expandCurrentMealCategory() {
    final hour = DateTime.now().hour;
    if (hour >= 7 && hour < 12) {
      _expandedCategories['Breakfast'] = true;
    } else if (hour >= 12 && hour < 19) {
      _expandedCategories['Lunch'] = true;
    } else {
      _expandedCategories['Dinner'] = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await MockDataService.getMessSchedule();
      setState(() {
        _messData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showItemDetails(Map<String, dynamic> item, bool isIncluded) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ItemDetailsSheet(item: item, isIncluded: isIncluded),
    );
  }

  void _showSuggestionDialog() {
    final controller = TextEditingController();
    String selectedType = 'Suggestion';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Share Your Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Type:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Suggestion', label: Text('Suggestion')),
                  ButtonSegment(value: 'Complaint', label: Text('Complaint')),
                ],
                selected: {selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setDialogState(() {
                    selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: selectedType == 'Suggestion'
                      ? 'Suggest a new item or improvement...'
                      : 'Describe your complaint...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Your $selectedType has been submitted!'),
                      backgroundColor: kSuccessGreen,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final status = _messData?['status'] ?? 'inactive';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mess Menu'),
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Included'),
            Tab(text: 'Extra/Paid'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: status == 'active' ? kSuccessGreen : kErrorRed,
            ),
            child: Row(
              children: [
                Icon(
                  status == 'active' ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status == 'active'
                        ? 'Your mess service is active'
                        : 'Mess service is currently inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Day Selector
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isSelected ? kBrandBlue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        _days[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildIncludedItems(),
                _buildExtraPaidItems(),
              ],
            ),
          ),

          // Suggestions Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showSuggestionDialog,
                      icon: const Icon(Icons.edit_note_outlined, size: 20),
                      label: const Text('Suggest or Report'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncludedItems() {
    final includedMenu = {
      'Breakfast': [
        {
          'name': 'Scrambled Eggs',
          'quantity': '2 eggs',
          'time': '07:00 - 10:00',
          'calories': '140 kcal',
          'protein': '12g',
          'description':
              'Fluffy scrambled eggs cooked to perfection with a hint of butter',
          'image':
              'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Pancakes',
          'quantity': '3 pieces',
          'time': '07:00 - 10:00',
          'calories': '350 kcal',
          'carbs': '45g',
          'description': 'Classic fluffy pancakes served with maple syrup',
          'image':
              'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Oatmeal Bowl',
          'quantity': '1 bowl',
          'time': '07:00 - 10:00',
          'calories': '150 kcal',
          'fiber': '4g',
          'description': 'Nutritious oatmeal with fresh fruits and honey',
          'image':
              'https://images.pexels.com/photos/3625372/pexels-photo-3625372.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
      'Lunch': [
        {
          'name': 'Grilled Chicken',
          'quantity': '200g',
          'time': '12:00 - 15:00',
          'calories': '280 kcal',
          'protein': '35g',
          'description': 'Tender grilled chicken breast with herbs and spices',
          'image':
              'https://images.pexels.com/photos/2338407/pexels-photo-2338407.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Caesar Salad',
          'quantity': '1 plate',
          'time': '12:00 - 15:00',
          'calories': '180 kcal',
          'fiber': '3g',
          'description':
              'Fresh romaine lettuce with parmesan and caesar dressing',
          'image':
              'https://images.pexels.com/photos/2097090/pexels-photo-2097090.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Rice & Daal',
          'quantity': 'Unlimited',
          'time': '12:00 - 15:00',
          'calories': '250 kcal per serving',
          'protein': '8g',
          'description': 'Traditional basmati rice with lentil curry',
          'image':
              'https://images.pexels.com/photos/4051617/pexels-photo-4051617.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
      'Dinner': [
        {
          'name': 'Pasta Alfredo',
          'quantity': '1 plate',
          'time': '19:00 - 22:00',
          'calories': '420 kcal',
          'carbs': '48g',
          'description': 'Creamy alfredo pasta with garlic bread',
          'image':
              'https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'BBQ Ribs',
          'quantity': '4 pieces',
          'time': '19:00 - 22:00',
          'calories': '480 kcal',
          'protein': '28g',
          'description': 'Slow-cooked BBQ ribs with special sauce',
          'image':
              'https://images.pexels.com/photos/3662104/pexels-photo-3662104.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Vegetable Stir Fry',
          'quantity': '1 plate',
          'time': '19:00 - 22:00',
          'calories': '180 kcal',
          'fiber': '6g',
          'description': 'Mixed vegetables stir-fried with soy sauce',
          'image':
              'https://images.pexels.com/photos/1640770/pexels-photo-1640770.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
      'Refreshment': [
        {
          'name': 'Coffee',
          'quantity': 'Unlimited',
          'time': 'All day',
          'calories': '5 kcal',
          'caffeine': '95mg',
          'description': 'Fresh brewed coffee',
          'image':
              'https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Fresh Juice',
          'quantity': '1 glass',
          'time': 'All day',
          'calories': '110 kcal',
          'vitamin_c': '100%',
          'description': 'Freshly squeezed seasonal fruit juice',
          'image':
              'https://images.pexels.com/photos/96974/pexels-photo-96974.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
    };

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: includedMenu.entries.map((category) {
          return _buildCollapsibleCategory(
            category.key,
            category.value,
            isIncluded: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExtraPaidItems() {
    final paidMenu = {
      'Breakfast': [
        {
          'name': 'French Toast',
          'quantity': '2 slices',
          'time': '07:00 - 10:00',
          'price': 150,
          'calories': '300 kcal',
          'description': 'Golden french toast with cinnamon and sugar',
          'image':
              'https://images.pexels.com/photos/103124/pexels-photo-103124.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Smoothie Bowl',
          'quantity': '1 bowl',
          'time': '07:00 - 10:00',
          'price': 200,
          'calories': '250 kcal',
          'description': 'Acai smoothie bowl topped with granola and fruits',
          'image':
              'https://images.pexels.com/photos/1092730/pexels-photo-1092730.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
      'Lunch': [
        {
          'name': 'Fish Tacos',
          'quantity': '3 pieces',
          'time': '12:00 - 15:00',
          'price': 350,
          'calories': '380 kcal',
          'description': 'Crispy fish tacos with fresh salsa',
          'image':
              'https://images.pexels.com/photos/7613568/pexels-photo-7613568.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Burger & Fries',
          'quantity': '1 set',
          'time': '12:00 - 15:00',
          'price': 400,
          'calories': '650 kcal',
          'description': 'Juicy beef burger with crispy french fries',
          'image':
              'https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
      'Dinner': [
        {
          'name': 'Steak',
          'quantity': '250g',
          'time': '19:00 - 22:00',
          'price': 800,
          'calories': '520 kcal',
          'description': 'Premium beef steak cooked to your preference',
          'image':
              'https://images.pexels.com/photos/769289/pexels-photo-769289.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Sushi Platter',
          'quantity': '10 pieces',
          'time': '19:00 - 22:00',
          'price': 600,
          'calories': '400 kcal',
          'description': 'Assorted fresh sushi with wasabi and soy sauce',
          'image':
              'https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
      'Refreshment': [
        {
          'name': 'Bottled Water',
          'quantity': '1 bottle',
          'time': 'All day',
          'price': 50,
          'calories': '0 kcal',
          'description': 'Premium mineral water',
          'image':
              'https://images.pexels.com/photos/416528/pexels-photo-416528.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
        {
          'name': 'Energy Drink',
          'quantity': '1 can',
          'time': 'All day',
          'price': 150,
          'calories': '110 kcal',
          'description': 'Popular energy drink',
          'image':
              'https://images.pexels.com/photos/2775860/pexels-photo-2775860.jpeg?auto=compress&cs=tinysrgb&w=600'
        },
      ],
    };

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: paidMenu.entries.map((category) {
          return _buildCollapsibleCategory(
            category.key,
            category.value,
            isIncluded: false,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCollapsibleCategory(
    String category,
    List<Map<String, dynamic>> items, {
    required bool isIncluded,
  }) {
    final isExpanded = _expandedCategories[category] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category Header - Tappable
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kBrandBlue.withOpacity(0.05),
                    kBrandBlue.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(16))
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBrandBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: kBrandBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kBrandBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${items.length} ${items.length == 1 ? 'item' : 'items'} available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: kBrandBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Menu Items
          if (isExpanded)
            Column(
              children: [
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: items
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: EdgeInsets.only(
                                bottom: entry.key < items.length - 1 ? 12 : 0,
                              ),
                              child: _buildMenuItem(entry.value, isIncluded),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isIncluded) {
    final hasImage =
        item['image'] != null && item['image'].toString().isNotEmpty;

    return InkWell(
      onTap: () => _showItemDetails(item, isIncluded),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Item Image or Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item['image'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.grey[400],
                    ),
            ),

            const SizedBox(width: 14),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item['time'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.local_dining,
                          size: 13, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item['quantity'],
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item['calories'] != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 13, color: Colors.orange[600]),
                        const SizedBox(width: 4),
                        Text(
                          item['calories'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Price or Just Arrow for Included
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isIncluded)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      'Rs ${item['price']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Breakfast':
        return Icons.free_breakfast;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      case 'Refreshment':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }
}

// Item Details Bottom Sheet
class _ItemDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isIncluded;

  const _ItemDetailsSheet({
    required this.item,
    required this.isIncluded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Image - Show if available, otherwise gradient placeholder
          if (item['image'] != null && item['image'].toString().isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                item['image'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    color: Colors.grey[100],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          kBrandBlue.withOpacity(0.1),
                          kBrandBlue.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 80,
                        color: kBrandBlue.withOpacity(0.3),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kBrandBlue.withOpacity(0.1),
                    kBrandBlue.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: kBrandBlue.withOpacity(0.3),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kBrandBlue,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isIncluded ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isIncluded ? 'Included' : 'Rs ${item['price']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isIncluded
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                if (item['description'] != null)
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),

                const SizedBox(height: 20),

                // Details Grid
                _buildDetailRow(Icons.access_time, 'Available', item['time']),
                const SizedBox(height: 12),
                _buildDetailRow(
                    Icons.restaurant_menu, 'Quantity', item['quantity']),
                if (item['calories'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.local_fire_department, 'Calories',
                      item['calories']),
                ],
                if (item['protein'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      Icons.fitness_center, 'Protein', item['protein']),
                ],
                if (item['carbs'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.bakery_dining, 'Carbs', item['carbs']),
                ],
                if (item['fiber'] != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.grass, 'Fiber', item['fiber']),
                ],

                const SizedBox(height: 20),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kBrandBlue),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
