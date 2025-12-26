// lib/screens/wallet/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import 'payment_method_screen.dart';

enum DueStatus { pending, overdue, paid, processing }

class DueItem {
  final String id;
  final String title;
  final String category;
  final double totalAmount;
  final double paidAmount;
  final DateTime dueDate;
  final DueStatus status;
  final String? description;

  DueItem({
    required this.id,
    required this.title,
    required this.category,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.dueDate,
    required this.status,
    this.description,
  });

  double get pendingAmount => totalAmount - paidAmount;
  bool get isFullyPaid => paidAmount >= totalAmount;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && !isFullyPaid;
  double get paymentProgress =>
      totalAmount > 0 ? (paidAmount / totalAmount) : 0;
}

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Mock data - replace with actual API calls
  final List<DueItem> _allDues = [
    DueItem(
      id: '1',
      title: 'Mess Fee',
      category: 'Monthly Charges',
      totalAmount: 4000,
      paidAmount: 0,
      dueDate: DateTime(2025, 1, 10),
      status: DueStatus.overdue,
      description: 'Monthly mess charges for January',
    ),
    DueItem(
      id: '2',
      title: 'Laundry Fee',
      category: 'Services',
      totalAmount: 7000,
      paidAmount: 0,
      dueDate: DateTime(2025, 1, 15),
      status: DueStatus.overdue,
      description: 'Laundry service charges',
    ),
    DueItem(
      id: '3',
      title: 'Service Charge',
      category: 'Penalties',
      totalAmount: 5000,
      paidAmount: 1000,
      dueDate: DateTime(2025, 1, 20),
      status: DueStatus.pending,
      description: 'Additional service charges',
    ),
    DueItem(
      id: '4',
      title: 'Room Rent',
      category: 'Monthly Charges',
      totalAmount: 18000,
      paidAmount: 0,
      dueDate: DateTime(2025, 1, 5),
      status: DueStatus.pending,
      description: 'January room rent',
    ),
    DueItem(
      id: '5',
      title: 'Electricity Bill',
      category: 'Utilities',
      totalAmount: 3500,
      paidAmount: 3500,
      dueDate: DateTime(2024, 12, 25),
      status: DueStatus.paid,
    ),
    DueItem(
      id: '6',
      title: 'December Rent',
      category: 'Monthly Charges',
      totalAmount: 17500,
      paidAmount: 17500,
      dueDate: DateTime(2024, 12, 5),
      status: DueStatus.paid,
    ),
  ];

  List<DueItem> get _pendingDues {
    final dues = _allDues.where((d) => !d.isFullyPaid).toList();
    // Sort by due date (nearest first), then by overdue status
    dues.sort((a, b) {
      if (a.isOverdue && !b.isOverdue) return -1;
      if (!a.isOverdue && b.isOverdue) return 1;
      return a.dueDate.compareTo(b.dueDate);
    });
    return dues;
  }

  List<DueItem> get _paidDues {
    return _allDues.where((d) => d.isFullyPaid).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }

  double get _totalPendingBalance {
    return _pendingDues.fold(0, (sum, due) => sum + due.pendingAmount);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPaymentOptions(DueItem due) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentOptionsSheet(
        due: due,
        onPaymentTypeSelected: (isFullPayment, customAmount) {
          final amount = isFullPayment ? due.pendingAmount : customAmount;
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentMethodScreen(
                amount: amount,
                dueItem: due,
              ),
            ),
          );
        },
      ),
    );
  }

  void _payAllDues() {
    if (_totalPendingBalance <= 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodScreen(
          amount: _totalPendingBalance,
          dueItem: null, // null means paying all dues
          allDues: _pendingDues,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            onPressed: () {
              // Transaction history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Transaction history coming soon')),
              );
            },
            icon: const Icon(Icons.history),
            tooltip: 'Transaction History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kBrandBlue, kBrandBlue.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kBrandBlue.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Total Pending Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Rs ${_totalPendingBalance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_pendingDues.length} ${_pendingDues.length == 1 ? 'due' : 'dues'} pending',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (_totalPendingBalance > 0) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _payAllDues,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: kBrandBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pay All Dues',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: kBrandBlue,
              labelColor: kBrandBlue,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: 'Pending (${_pendingDues.length})'),
                Tab(text: 'Paid (${_paidDues.length})'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(),
                _buildPaidTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingDues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No pending dues',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All caught up!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _isLoading = true);
        await Future.delayed(const Duration(seconds: 1));
        setState(() => _isLoading = false);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingDues.length,
        itemBuilder: (context, index) {
          return _buildDueCard(_pendingDues[index]);
        },
      ),
    );
  }

  Widget _buildPaidTab() {
    if (_paidDues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No paid dues',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paidDues.length,
      itemBuilder: (context, index) {
        return _buildPaidCard(_paidDues[index]);
      },
    );
  }

  Widget _buildDueCard(DueItem due) {
    final isOverdue = due.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? kErrorRed.withOpacity(0.3) : Colors.grey[200]!,
          width: isOverdue ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        due.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? kErrorRed.withOpacity(0.1)
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOverdue ? 'OVERDUE' : 'PENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOverdue ? kErrorRed : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Due: ${DateFormat('d MMM').format(due.dueDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOverdue ? kErrorRed : Colors.grey[600],
                        fontWeight:
                            isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.category_outlined,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      due.category,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs ${due.totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (due.paidAmount > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Paid',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs ${due.paidAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kSuccessGreen,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Progress Section (if partial payment made)
          if (due.paidAmount > 0) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${(due.paymentProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kSuccessGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: due.paymentProgress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(kSuccessGreen),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pending: Rs ${due.pendingAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Pay Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showPaymentOptions(due),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pay Rs ${due.pendingAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  Widget _buildPaidCard(DueItem due) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kSuccessGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.check_circle, color: kSuccessGreen, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  due.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid on ${DateFormat('d MMM yyyy').format(due.dueDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            'Rs ${due.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Payment Options Bottom Sheet
class _PaymentOptionsSheet extends StatefulWidget {
  final DueItem due;
  final Function(bool isFullPayment, double customAmount) onPaymentTypeSelected;

  const _PaymentOptionsSheet({
    required this.due,
    required this.onPaymentTypeSelected,
  });

  @override
  State<_PaymentOptionsSheet> createState() => _PaymentOptionsSheetState();
}

class _PaymentOptionsSheetState extends State<_PaymentOptionsSheet> {
  bool _isFullPayment = true;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Payment Type',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kBrandBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.due.title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),

                // Full Payment Option
                GestureDetector(
                  onTap: () => setState(() => _isFullPayment = true),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isFullPayment
                          ? kBrandBlue.withOpacity(0.1)
                          : Colors.grey[50],
                      border: Border.all(
                        color: _isFullPayment ? kBrandBlue : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isFullPayment
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: _isFullPayment ? kBrandBlue : Colors.grey[400],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pay Full Amount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rs ${widget.due.pendingAmount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: kBrandBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Partial Payment Option
                GestureDetector(
                  onTap: () => setState(() => _isFullPayment = false),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !_isFullPayment
                          ? kBrandBlue.withOpacity(0.1)
                          : Colors.grey[50],
                      border: Border.all(
                        color: !_isFullPayment ? kBrandBlue : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              !_isFullPayment
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: !_isFullPayment
                                  ? kBrandBlue
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Pay Partial Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (!_isFullPayment) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Enter Amount',
                              hintText: 'Min Rs 100',
                              prefixText: 'Rs ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Proceed Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_isFullPayment) {
                        widget.onPaymentTypeSelected(true, 0);
                      } else {
                        final amount =
                            double.tryParse(_amountController.text) ?? 0;
                        if (amount < 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Minimum payment amount is Rs 100'),
                              backgroundColor: kErrorRed,
                            ),
                          );
                          return;
                        }
                        if (amount > widget.due.pendingAmount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Amount cannot exceed pending balance'),
                              backgroundColor: kErrorRed,
                            ),
                          );
                          return;
                        }
                        widget.onPaymentTypeSelected(false, amount);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Proceed to Payment',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
