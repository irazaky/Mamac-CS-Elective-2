class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role; // 'customer' or 'admin'

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}
