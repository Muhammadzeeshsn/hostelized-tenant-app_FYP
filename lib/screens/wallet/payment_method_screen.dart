// lib/screens/wallet/payment_method_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';
import 'wallet_screen.dart';
import 'payment_process_screen.dart';

enum PaymentMethodType { oneLink, raastQR, walletPayment, cardPayment }

class PaymentMethod {
  final PaymentMethodType type;
  final String name;
  final String description;
  final double feePercentage;
  final IconData icon;

  PaymentMethod({
    required this.type,
    required this.name,
    required this.description,
    required this.feePercentage,
    required this.icon,
  });

  double calculateFee(double amount) => amount * (feePercentage / 100);

  String get feeLabel {
    if (feePercentage == 0) return 'Free';
    return '$feePercentage% fee';
  }
}

class PaymentMethodScreen extends StatefulWidget {
  final double amount;
  final DueItem? dueItem; // null if paying all dues
  final List<DueItem>? allDues;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    this.dueItem,
    this.allDues,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethodType? _selectedMethod;

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      type: PaymentMethodType.oneLink,
      name: '1LINK',
      description: 'Pay via any banking app',
      feePercentage: 0,
      icon: Icons.account_balance,
    ),
    PaymentMethod(
      type: PaymentMethodType.raastQR,
      name: 'Raast QR Scan',
      description: 'Scan QR via banking app',
      feePercentage: 0.25,
      icon: Icons.qr_code_scanner,
    ),
    PaymentMethod(
      type: PaymentMethodType.walletPayment,
      name: 'Wallet Payments',
      description: 'JazzCash, EasyPaisa',
      feePercentage: 1,
      icon: Icons.account_balance_wallet,
    ),
    PaymentMethod(
      type: PaymentMethodType.cardPayment,
      name: 'Card Payment',
      description: 'Credit/Debit Card',
      feePercentage: 2,
      icon: Icons.credit_card,
    ),
  ];

  PaymentMethod? get _selectedPaymentMethod {
    if (_selectedMethod == null) return null;
    return _paymentMethods.firstWhere((m) => m.type == _selectedMethod);
  }

  double get _totalAmount {
    if (_selectedPaymentMethod == null) return widget.amount;
    return widget.amount + _selectedPaymentMethod!.calculateFee(widget.amount);
  }

  void _proceedToPayment() {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: kErrorRed,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentProcessScreen(
          amount: widget.amount,
          totalAmount: _totalAmount,
          paymentMethod: _selectedPaymentMethod!,
          dueItem: widget.dueItem,
          allDues: widget.allDues,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Method'),
      ),
      body: Column(
        children: [
          // Amount Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                Text(
                  'Amount to Pay',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs ${widget.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: kBrandBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.dueItem != null
                      ? widget.dueItem!.title
                      : 'Paying ${widget.allDues?.length ?? 0} dues',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                if (_selectedPaymentMethod != null &&
                    _selectedPaymentMethod!.feePercentage > 0) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Processing Fee',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '+Rs ${_selectedPaymentMethod!.calculateFee(widget.amount).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Rs ${_totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kBrandBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Payment Methods Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Payment Methods List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                return _buildPaymentMethodCard(_paymentMethods[index]);
              },
            ),
          ),

          // Processing Fee Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              border: Border(
                top: BorderSide(color: Colors.amber[200]!),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.amber[900]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'The processing fee will be added to your payment amount and shown before final confirmation',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Proceed Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _proceedToPayment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _selectedMethod != null
                          ? 'Proceed to Payment'
                          : 'Select Payment Method',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedMethod == method.type;
    final fee = method.calculateFee(widget.amount);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method.type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kBrandBlue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kBrandBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected ? kBrandBlue.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                method.icon,
                color: isSelected ? kBrandBlue : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? kBrandBlue : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: method.feePercentage == 0
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    method.feeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: method.feePercentage == 0
                          ? Colors.green[700]
                          : Colors.orange[700],
                    ),
                  ),
                ),
                if (method.feePercentage > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+Rs ${fee.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
