class TeacherModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String authId;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.authId,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'teacher',
      status: map['status'] ?? 'active',
      authId: map['auth_user_id'] ?? '',
    );
  }
}
