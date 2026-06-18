class TeacherModel {
  final String? id;

  final String fullName;
  final String icNumber;

  final String? gender;
  final String? dob;

  final String? address;
  final String? postcode;
  final String? state;

  final String? phone;
  final String? email;

  final String? maritalStatus;

  final String? emergencyName;
  final String? emergencyPhone;
  final String? avatarUrl;
  final String status; // pending, approved, rejected

  TeacherModel({
    this.id,
    required this.fullName,
    required this.icNumber,
    this.gender,
    this.dob,
    this.address,
    this.postcode,
    this.state,
    this.phone,
    this.email,
    this.maritalStatus,
    this.emergencyName,
    this.emergencyPhone,
    this.avatarUrl,
    this.status = 'pending',
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'],
      fullName: map['full_name'],
      icNumber: map['ic_number'],
      gender: map['gender'],
      dob: map['dob'],
      address: map['address'],
      postcode: map['postcode'],
      state: map['state'],
      phone: map['phone'],
      email: map['email'],
      maritalStatus: map['marital_status'],
      emergencyName: map['emergency_name'],
      emergencyPhone: map['emergency_phone'],
      avatarUrl: map['avatar_url'],
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'ic_number': icNumber,
      'gender': gender,
      'dob': dob,
      'address': address,
      'postcode': postcode,
      'state': state,
      'phone': phone,
      'email': email,
      'marital_status': maritalStatus,
      'emergency_name': emergencyName,
      'emergency_phone': emergencyPhone,
      'avatar_url': avatarUrl,
      'status': status,
    };
  }
}