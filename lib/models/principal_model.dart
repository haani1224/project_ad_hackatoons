class PrincipalModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String password;

  PrincipalModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'principal',required this.status,
    required this.password,
  });

  factory PrincipalModel.fromMap(Map<String, dynamic> map) {
    return PrincipalModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'principal',
      status: map['status'] ?? 'active',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'status': status,
        'password': password,
      };
}