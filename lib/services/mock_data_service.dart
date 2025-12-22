// lib/services/mock_data_service.dart

import '../models/home.dart';
import '../models/invoice.dart';

/// Mock data service for testing before backend integration
/// Replace all methods with actual API calls later
class MockDataService {
  // ============================================================================
  // HOME DATA
  // ============================================================================

  static Future<TenantHome> getHomeData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return TenantHome.fromJson({
      'tenant': {
        'id': '59b46b4d-904d-4827-a005-2f7f073ba260',
        'firstName': 'Muhammad',
        'lastName': 'Zeeshan',
        'username': 'SEEDA260',
        'email': 'mzeeshan7242@gmail.com',
        'phone': '0987654321',
        'personalId': 'MZ-2024-001',
        'program': 'Computer Science',
        'rollNumber': 'CS-2020-001',
        'avatarUrl': '', // Empty for placeholder
        'dateOfBirth': '2007-12-01',
        'gender': 'Male',
      },
      'room': {
        'id': 'room-101',
        'roomNumber': '101',
        'floor': '1',
        'building': 'A Block',
        'capacity': 2,
        'occupancy': 1,
        'type': 'Double',
        'monthlyRent': 3000,
      },
      'hostel': {
        'id': 'hostel-1',
        'name': 'Punjab Hostel',
        'address': 'Model Town, Lahore',
        'contactNumber': '+92 300 1234567',
        'email': 'punjabhostel@example.com',
        'amenities': ['WiFi', 'Laundry', 'Mess', 'Security'],
      },
      'balance': {
        'totalDues': 19000,
        'totalDiscount': 1000,
        'totalPayable': 18000,
        'breakdown': [
          {'name': 'Mess Fee', 'amount': 4000, 'discount': 0},
          {'name': 'Hostel Fee', 'amount': 3000, 'discount': 0},
          {'name': 'Laundry Fee', 'amount': 7000, 'discount': 0},
          {'name': 'Service Charge', 'amount': 5000, 'discount': 1000},
        ],
        'dueDate': '2025-01-31',
      },
      'notices': [
        {
          'id': 'notice-1',
          'title': 'Fee Payment Reminder',
          'message':
              'Last Date to pay Hostel Fees is 31/01/2025 for the month of January.',
          'priority': 'high',
          'read': false,
          'createdAt': '2025-01-15T10:00:00Z',
        },
        {
          'id': 'notice-2',
          'title': 'Service Request Update',
          'message':
              'Your service request was completed yesterday. Head to the ticket section to provide your feedback!',
          'priority': 'normal',
          'read': false,
          'createdAt': '2025-01-14T15:30:00Z',
        },
        {
          'id': 'notice-3',
          'title': 'Mess Schedule',
          'message':
              'Your mess has been turned off from 29/01/2025 to 05/02/2025.',
          'priority': 'normal',
          'read': false,
          'createdAt': '2025-01-13T09:00:00Z',
        },
        {
          'id': 'notice-4',
          'title': 'Service Reschedule Required',
          'message':
              'Your Service request for house keeping on 30/01/2025 could not be completed. Kindly reschedule.',
          'priority': 'normal',
          'read': false,
          'createdAt': '2025-01-12T14:00:00Z',
        },
      ],
    });
  }

  // ============================================================================
  // INVOICES DATA
  // ============================================================================

  static Future<Paged<Invoice>> getInvoices({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allInvoices = [
      Invoice.fromJson({
        'id': 'inv-001',
        'period': 'January 2025',
        'amount': 18000,
        'status': 'pending',
        'issuedAt': '2025-01-01T00:00:00Z',
        'dueAt': '2025-01-31T23:59:59Z',
        'paidAt': null,
      }),
      Invoice.fromJson({
        'id': 'inv-002',
        'period': 'December 2024',
        'amount': 17500,
        'status': 'paid',
        'issuedAt': '2024-12-01T00:00:00Z',
        'dueAt': '2024-12-31T23:59:59Z',
        'paidAt': '2024-12-15T10:30:00Z',
      }),
      Invoice.fromJson({
        'id': 'inv-003',
        'period': 'November 2024',
        'amount': 18000,
        'status': 'paid',
        'issuedAt': '2024-11-01T00:00:00Z',
        'dueAt': '2024-11-30T23:59:59Z',
        'paidAt': '2024-11-10T14:20:00Z',
      }),
      Invoice.fromJson({
        'id': 'inv-004',
        'period': 'October 2024',
        'amount': 17000,
        'status': 'paid',
        'issuedAt': '2024-10-01T00:00:00Z',
        'dueAt': '2024-10-31T23:59:59Z',
        'paidAt': '2024-10-12T09:15:00Z',
      }),
      Invoice.fromJson({
        'id': 'inv-005',
        'period': 'September 2024',
        'amount': 18500,
        'status': 'overdue',
        'issuedAt': '2024-09-01T00:00:00Z',
        'dueAt': '2024-09-30T23:59:59Z',
        'paidAt': null,
      }),
    ];

    // Filter by status if provided
    final filtered = status != null
        ? allInvoices.where((inv) => inv.status == status).toList()
        : allInvoices;

    return Paged(
      items: filtered,
      total: filtered.length,
      page: page,
      pageSize: pageSize,
    );
  }

  // ============================================================================
  // TICKETS/SUPPORT DATA
  // ============================================================================

  static Future<Map<String, dynamic>> getTickets({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'items': [
        {
          'id': 'ticket-001',
          'subject': 'Bathroom Plumbing Issue',
          'category': 'Maintenance',
          'status': 'in_progress',
          'priority': 'high',
          'createdAt': '2025-01-18T08:00:00Z',
          'updatedAt': '2025-01-19T10:00:00Z',
          'description': 'Water leakage in bathroom sink',
        },
        {
          'id': 'ticket-002',
          'subject': 'WiFi Not Working',
          'category': 'Technical',
          'status': 'resolved',
          'priority': 'medium',
          'createdAt': '2025-01-15T14:30:00Z',
          'updatedAt': '2025-01-16T09:00:00Z',
          'description': 'Cannot connect to hostel WiFi network',
        },
        {
          'id': 'ticket-003',
          'subject': 'Room Cleaning Request',
          'category': 'Housekeeping',
          'status': 'pending',
          'priority': 'low',
          'createdAt': '2025-01-20T11:00:00Z',
          'updatedAt': '2025-01-20T11:00:00Z',
          'description': 'Request for room deep cleaning',
        },
      ],
      'total': 3,
      'page': page,
      'pageSize': pageSize,
    };
  }

  // ============================================================================
  // PAYMENT HISTORY
  // ============================================================================

  static Future<Map<String, dynamic>> getPaymentHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'items': [
        {
          'id': 'pay-001',
          'invoiceId': 'inv-002',
          'amount': 17500,
          'method': 'Online',
          'status': 'completed',
          'transactionId': 'TXN123456789',
          'paidAt': '2024-12-15T10:30:00Z',
        },
        {
          'id': 'pay-002',
          'invoiceId': 'inv-003',
          'amount': 18000,
          'method': 'Cash',
          'status': 'completed',
          'transactionId': 'TXN987654321',
          'paidAt': '2024-11-10T14:20:00Z',
        },
      ],
      'total': 2,
      'page': page,
      'pageSize': pageSize,
    };
  }

  // ============================================================================
  // ROOM DETAILS
  // ============================================================================

  static Future<Map<String, dynamic>?> getRoomDetails() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'id': 'room-101',
      'roomNumber': '101',
      'floor': '1',
      'building': 'A Block',
      'capacity': 2,
      'occupancy': 1,
      'type': 'Double',
      'monthlyRent': 3000,
      'facilities': ['Bed', 'Study Table', 'Chair', 'Wardrobe', 'Fan', 'Light'],
      'roommates': [
        {
          'id': 'tenant-2',
          'name': 'Ahmed Ali',
          'avatarUrl': '',
          'program': 'Electrical Engineering',
        },
      ],
    };
  }

  // ============================================================================
  // MESS SCHEDULE
  // ============================================================================

  static Future<Map<String, dynamic>> getMessSchedule() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'status': 'active',
      'currentPlan': 'Full Board',
      'monthlyFee': 4000,
      'schedule': {
        'Monday': {
          'breakfast': 'Paratha, Chai, Eggs',
          'lunch': 'Rice, Daal, Chicken Curry',
          'dinner': 'Roti, Vegetables, Yogurt',
        },
        'Tuesday': {
          'breakfast': 'Halwa Puri, Chai',
          'lunch': 'Biryani, Raita',
          'dinner': 'Rice, Daal, Fish',
        },
        'Wednesday': {
          'breakfast': 'Paratha, Chai, Omelette',
          'lunch': 'Rice, Beef Curry, Salad',
          'dinner': 'Roti, Daal, Vegetables',
        },
        // Add more days...
      },
      'offDates': ['2025-01-29', '2025-01-30', '2025-02-01', '2025-02-05'],
    };
  }

  // ============================================================================
  // PROFILE DATA
  // ============================================================================

  static Future<Map<String, dynamic>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'id': '59b46b4d-904d-4827-a005-2f7f073ba260',
      'username': 'SEEDA260',
      'firstName': 'Muhammad',
      'lastName': 'Zeeshan',
      'email': 'mzeeshan7242@gmail.com',
      'phone': '0987654321',
      'personalId': 'MZ-2024-001',
      'program': 'Computer Science',
      'rollNumber': 'CS-2020-001',
      'dateOfBirth': '2007-12-01',
      'gender': 'Male',
      'avatarUrl': '',
      'address': {
        'current': {
          'country': 'Pakistan',
          'city': 'Lahore',
          'street': 'Model Town',
        },
        'permanent': {
          'country': 'Pakistan',
          'city': 'Islamabad',
          'street': 'F-7 Sector',
        },
      },
      'guardian': {
        'name': 'Ali Zeeshan',
        'phone': '+92 321 1234567',
        'relation': 'Father',
      },
      'joinedAt': '2024-09-01T00:00:00Z',
      'registrationComplete': true,
    };
  }
}
