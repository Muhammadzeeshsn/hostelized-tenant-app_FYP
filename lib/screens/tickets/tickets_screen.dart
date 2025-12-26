// lib/screens/tickets/tickets_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import 'ticket_chat_screen.dart';
import 'ticket_review_screen.dart';

enum TicketStatus { all, active, pending, resolved }

enum TicketPriority { low, medium, high, urgent }

class Ticket {
  final String id;
  final String title;
  final String category;
  final String description;
  final TicketPriority priority;
  final String status; // 'active', 'pending', 'resolved'
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final int unreadCount;
  final String? lastMessage;
  final bool canReview;
  final double? rating;

  Ticket({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
    this.unreadCount = 0,
    this.lastMessage,
    this.canReview = false,
    this.rating,
  });
}

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  TicketStatus _selectedFilter = TicketStatus.all;
  bool _isLoading = false;

  // Mock data - replace with actual API call
  final List<Ticket> _mockTickets = [
    Ticket(
      id: '1',
      title: 'AC not working',
      category: 'Maintenance',
      description: 'The AC in my room has stopped working',
      priority: TicketPriority.high,
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 2,
      lastMessage: 'Our technician will visit tomorrow',
    ),
    Ticket(
      id: '2',
      title: 'Water leakage',
      category: 'Plumbing',
      description: 'Water is leaking from bathroom ceiling',
      priority: TicketPriority.urgent,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      lastMessage: 'Please send photos of the issue',
    ),
    Ticket(
      id: '3',
      title: 'WiFi connection issue',
      category: 'Internet',
      description: 'Unable to connect to hostel WiFi',
      priority: TicketPriority.medium,
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
      lastMessage: 'Issue has been resolved',
      canReview: true,
    ),
    Ticket(
      id: '4',
      title: 'Room key lost',
      category: 'Security',
      description: 'I lost my room key, need replacement',
      priority: TicketPriority.high,
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      resolvedAt: DateTime.now().subtract(const Duration(days: 4)),
      unreadCount: 0,
      lastMessage: 'New key issued',
      canReview: false,
      rating: 4.5,
    ),
  ];

  List<Ticket> get _filteredTickets {
    switch (_selectedFilter) {
      case TicketStatus.all:
        return _mockTickets;
      case TicketStatus.active:
        return _mockTickets.where((t) => t.status == 'active').toList();
      case TicketStatus.pending:
        return _mockTickets.where((t) => t.status == 'pending').toList();
      case TicketStatus.resolved:
        return _mockTickets.where((t) => t.status == 'resolved').toList();
    }
  }

  void _showCreateTicketDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Maintenance';
    TicketPriority selectedPriority = TicketPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Brief description of issue',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    'Maintenance',
                    'Plumbing',
                    'Electrical',
                    'Internet',
                    'Security',
                    'Other'
                  ]
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TicketPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TicketPriority.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(_getPriorityLabel(p)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedPriority = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Detailed description of the issue',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty &&
                    descController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ticket created successfully!'),
                      backgroundColor: kSuccessGreen,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Support Tickets'),
        actions: [
          IconButton(
            onPressed: _showCreateTicketDialog,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Create Ticket',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                      TicketStatus.all, 'All', _mockTickets.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    TicketStatus.active,
                    'Active',
                    _mockTickets.where((t) => t.status == 'active').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    TicketStatus.pending,
                    'Pending',
                    _mockTickets.where((t) => t.status == 'pending').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    TicketStatus.resolved,
                    'Resolved',
                    _mockTickets.where((t) => t.status == 'resolved').length,
                  ),
                ],
              ),
            ),
          ),

          // Tickets List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTickets.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() => _isLoading = true);
                          await Future.delayed(const Duration(seconds: 1));
                          setState(() => _isLoading = false);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTickets.length,
                          itemBuilder: (context, index) {
                            return _buildTicketCard(_filteredTickets[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(TicketStatus status, String label, int count) {
    final isSelected = _selectedFilter == status;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : kBrandBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? kBrandBlue : Colors.black87,
              ),
            ),
          ),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = status);
        }
      },
      selectedColor: kBrandBlue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPriorityColor(ticket.priority).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (ticket.status == 'resolved' && ticket.canReview) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketReviewScreen(ticket: ticket),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketChatScreen(ticket: ticket),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(ticket.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getPriorityColor(ticket.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 12,
                          color: _getPriorityColor(ticket.priority),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPriorityLabel(ticket.priority),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(ticket.priority),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (ticket.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: kErrorRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${ticket.unreadCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                ticket.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              // Category
              Row(
                children: [
                  Icon(Icons.category_outlined,
                      size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    ticket.category,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              if (ticket.lastMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.message_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ticket.lastMessage!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _getTimeAgo(ticket.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (ticket.status == 'resolved' && ticket.canReview)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rate_review,
                              size: 14, color: Colors.orange[700]),
                          const SizedBox(width: 6),
                          Text(
                            'Review',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (ticket.rating != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          ticket.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    )
                  else
                    Icon(Icons.arrow_forward_ios,
                        size: 14, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tickets found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a ticket to get support',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showCreateTicketDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Ticket'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blue[700]!;
      case 'pending':
        return Colors.orange[700]!;
      case 'resolved':
        return kSuccessGreen;
      default:
        return Colors.grey[700]!;
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green[700]!;
      case TicketPriority.medium:
        return Colors.orange[700]!;
      case TicketPriority.high:
        return Colors.deepOrange[700]!;
      case TicketPriority.urgent:
        return kErrorRed;
    }
  }

  String _getPriorityLabel(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
