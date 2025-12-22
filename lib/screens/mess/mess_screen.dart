// lib/screens/mess/mess_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/mock_data_service.dart';

const _brandBlue = Color(0xFF003A60);

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
  int _selectedDayIndex = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
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
        backgroundColor: _brandBlue,
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
              color: status == 'active' ? Colors.green : Colors.red,
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
            height: 60,
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
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? _brandBlue : Colors.grey[200],
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
        ],
      ),
    );
  }

  Widget _buildIncludedItems() {
    // Mock included menu items
    final includedMenu = {
      'Breakfast': [
        {
          'name': 'Scrambled Eggs',
          'quantity': '2 eggs',
          'time': '07:00 - 10:00',
          'image': null
        },
        {
          'name': 'Pancakes',
          'quantity': '3 pieces',
          'time': '07:00 - 10:00',
          'image': null
        },
        {
          'name': 'Oatmeal Bowl',
          'quantity': '1 bowl',
          'time': '07:00 - 10:00',
          'image': null
        },
      ],
      'Lunch': [
        {
          'name': 'Grilled Chicken',
          'quantity': '200g',
          'time': '12:00 - 15:00',
          'image': null
        },
        {
          'name': 'Caesar Salad',
          'quantity': '1 plate',
          'time': '12:00 - 15:00',
          'image': null
        },
        {
          'name': 'Rice & Daal',
          'quantity': 'Unlimited',
          'time': '12:00 - 15:00',
          'image': null
        },
      ],
      'Dinner': [
        {
          'name': 'Pasta Alfredo',
          'quantity': '1 plate',
          'time': '19:00 - 22:00',
          'image': null
        },
        {
          'name': 'BBQ Ribs',
          'quantity': '4 pieces',
          'time': '19:00 - 22:00',
          'image': null
        },
        {
          'name': 'Vegetable Stir Fry',
          'quantity': '1 plate',
          'time': '19:00 - 22:00',
          'image': null
        },
      ],
      'Refreshment': [
        {
          'name': 'Coffee',
          'quantity': 'Unlimited',
          'time': 'All day',
          'image': null
        },
        {
          'name': 'Fresh Juice',
          'quantity': '1 glass',
          'time': 'All day',
          'image': null
        },
      ],
    };

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: includedMenu.entries.map((category) {
          return _buildCategorySection(
            category.key,
            category.value,
            isIncluded: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExtraPaidItems() {
    // Mock extra/paid menu items
    final paidMenu = {
      'Breakfast': [
        {
          'name': 'French Toast',
          'quantity': '2 slices',
          'time': '07:00 - 10:00',
          'price': 150,
          'image': null
        },
        {
          'name': 'Smoothie Bowl',
          'quantity': '1 bowl',
          'time': '07:00 - 10:00',
          'price': 200,
          'image': null
        },
      ],
      'Lunch': [
        {
          'name': 'Fish Tacos',
          'quantity': '3 pieces',
          'time': '12:00 - 15:00',
          'price': 350,
          'image': null
        },
        {
          'name': 'Burger & Fries',
          'quantity': '1 set',
          'time': '12:00 - 15:00',
          'price': 400,
          'image': null
        },
      ],
      'Dinner': [
        {
          'name': 'Steak',
          'quantity': '250g',
          'time': '19:00 - 22:00',
          'price': 800,
          'image': null
        },
        {
          'name': 'Sushi Platter',
          'quantity': '10 pieces',
          'time': '19:00 - 22:00',
          'price': 600,
          'image': null
        },
      ],
      'Refreshment': [
        {
          'name': 'Bottled Water',
          'quantity': '1 bottle',
          'time': 'All day',
          'price': 50,
          'image': null
        },
        {
          'name': 'Energy Drink',
          'quantity': '1 can',
          'time': 'All day',
          'price': 150,
          'image': null
        },
      ],
    };

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: paidMenu.entries.map((category) {
          return _buildCategorySection(
            category.key,
            category.value,
            isIncluded: false,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategorySection(
    String category,
    List<Map<String, dynamic>> items, {
    required bool isIncluded,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: _brandBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _brandBlue,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          ...items.map((item) => _buildMenuItem(item, isIncluded)).toList(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item, bool isIncluded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Image or Placeholder
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: item['image'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['image'],
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.restaurant,
                      size: 35,
                      color: Colors.grey[400],
                    ),
            ),

            const SizedBox(width: 12),

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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item['time'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item['quantity'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price or Included Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isIncluded ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isIncluded ? 'Included' : 'Rs ${item['price']}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isIncluded ? Colors.green[700] : Colors.orange[700],
                ),
              ),
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
