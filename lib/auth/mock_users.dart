// lib/auth/mock_users.dart

class MockUser {
  final String username;
  final String password;
  const MockUser(this.username, this.password);
}

const mockUsers = <MockUser>[
  MockUser('ali.khan', 'Ali@123'),
  MockUser('fatima.zaidi', 'Fatima456'),
  MockUser('zeeshan', 'Zeeshan786'),
];
