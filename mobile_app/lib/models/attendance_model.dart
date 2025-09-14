// models/attendance_model.dart

class AttendanceRecord {
  final String period;
  final String status;
  final String markedBy;

  AttendanceRecord({
    required this.period,
    required this.status,
    required this.markedBy,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      period: json['period'] ?? 'N/A',
      status: json['status'] ?? 'Unknown',
      markedBy: json['markedBy'] ?? 'Unknown Teacher',
    );
  }
}

class DailyAttendance {
  final String date;
  final List<AttendanceRecord> records;

  DailyAttendance({required this.date, required this.records});

  factory DailyAttendance.fromJson(Map<String, dynamic> json) {
    var recordsList = json['attendance'] as List;
    List<AttendanceRecord> parsedRecords = recordsList.map((i) => AttendanceRecord.fromJson(i)).toList();
    
    return DailyAttendance(
      date: json['date'] ?? 'Unknown Date',
      records: parsedRecords,
    );
  }
}