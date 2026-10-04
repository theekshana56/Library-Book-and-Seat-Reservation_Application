class SeatBooking {
  final String id;
  final String userId;
  final String seatCode;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? createdAt;
  final String? checkInTime;

  SeatBooking({
    required this.id,
    required this.userId,
    required this.seatCode,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.createdAt,
    this.checkInTime,
  });

  factory SeatBooking.fromJson(Map<String, dynamic> json) {
    return SeatBooking(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      seatCode: json['seatCode']?.toString() ?? '',
      bookingDate: json['bookingDate']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
      checkInTime: json['checkInTime']?.toString(),
    );
  }
}