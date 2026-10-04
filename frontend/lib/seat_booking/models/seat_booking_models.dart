class SeatMapSeat {
  final String id;
  final String seatCode;
  final String hallCode;
  final String floor;
  final String zone;

  final bool hasPowerOutlet;

  final int acousticsDb;

  final List<String> features;

  final bool available;

  const SeatMapSeat({
    required this.id,
    required this.seatCode,
    required this.hallCode,
    required this.floor,
    required this.zone,
    required this.hasPowerOutlet,
    required this.acousticsDb,
    required this.features,
    required this.available,
  });

  factory SeatMapSeat.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawFeatures =
        json['features'];

    return SeatMapSeat(
      id:
          json['id']
              ?.toString() ??
          '',

      seatCode:
          json['seatCode']
              ?.toString() ??
          '',

      hallCode:
          json['hallCode']
              ?.toString() ??
          '',

      floor:
          json['floor']
              ?.toString() ??
          '',

      zone:
          json['zone']
              ?.toString() ??
          '',

      hasPowerOutlet:
          json['hasPowerOutlet'] ==
          true,

      acousticsDb:
          (json['acousticsDb']
                      as num?)
                  ?.toInt() ??
              0,

      features:
          rawFeatures is List
              ? rawFeatures
                  .map(
                    (item) =>
                        item.toString(),
                  )
                  .toList()
              : const [],

      available:
          json['available'] ==
          true,
    );
  }
}

class SeatBookingRecord {
  final String id;

  final String userId;

  final String seatCode;

  final String bookingDate;

  final String startTime;

  final String endTime;

  final String status;

  final String? createdAt;

  final String? checkInTime;

  const SeatBookingRecord({
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

  factory SeatBookingRecord.fromJson(
    Map<String, dynamic> json,
  ) {
    return SeatBookingRecord(
      id:
          json['id']
              ?.toString() ??
          '',

      userId:
          json['userId']
              ?.toString() ??
          '',

      seatCode:
          json['seatCode']
              ?.toString() ??
          '',

      bookingDate:
          json['bookingDate']
              ?.toString() ??
          '',

      startTime:
          json['startTime']
              ?.toString() ??
          '',

      endTime:
          json['endTime']
              ?.toString() ??
          '',

      status:
          json['status']
              ?.toString() ??
          '',

      createdAt:
          json['createdAt']
              ?.toString(),

      checkInTime:
          json['checkInTime']
              ?.toString(),
    );
  }
}