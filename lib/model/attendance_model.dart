class Attendance {
  final int? id;
  final String? attendanceDate;
  final String? checkIn;
  final String? checkOut;
  final String? address;
  final double? lat;
  final double? lng;

  Attendance({this.id, this.attendanceDate, this.checkIn, this.checkOut, this.address, this.lat, this.lng});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      attendanceDate: json['attendance_date'],
      checkIn: json['check_in_time'] ?? json['check_in'],
      checkOut: json['check_out_time'] ?? json['check_out'],
      address: json['check_in_address'],
      lat: json['check_in_lat'] != null
          ? double.tryParse(json['check_in_lat'].toString())
          : null,
      lng: json['check_in_lng'] != null
          ? double.tryParse(json['check_in_lng'].toString())
          : null,
    );
  }
}
