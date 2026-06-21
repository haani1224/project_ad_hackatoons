class AttendanceLog {
  final String id;
  final String date;
  final String status;
  final String checkInTime;
  final String checkOutTime;

  AttendanceLog({
    required this.id,
    required this.date,
    required this.status,
    required this.checkInTime,
    required this.checkOutTime,
  });

  // 🟢 FUNGSI BARU BUAT NANGKEP DATA DARI SUPABASE
  factory AttendanceLog.fromMap(Map<String, dynamic> map) {
    return AttendanceLog(
      // Kalau id-nya int dari Supabase, toString() akan amanin
      id: map['id']?.toString() ?? '',
      
      // Ambil tanggal, misalnya dari kolom 'date' atau 'created_at'
      date: map['date'] ?? map['created_at']?.toString().substring(0, 10) ?? '',
      
      // Ambil status, kalau kosong defaultnya 'Present'
      status: map['status'] ?? 'Present',
      
      // Ambil jam masuk & keluar
      checkInTime: map['check_in_time'] ?? '--:--',
      checkOutTime: map['check_out_time'] ?? '--:--',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'status': status,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }
}