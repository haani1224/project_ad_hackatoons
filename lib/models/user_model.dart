class TeacherModel {
  final int id;
  final String name;
  final String email;
  final String status;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      status: map['status'],
    );
  }
}