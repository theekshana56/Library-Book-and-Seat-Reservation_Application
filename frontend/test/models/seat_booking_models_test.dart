import 'package:biblione/seat_booking/models/seat_booking_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SeatMapSeat.fromJson parses values and converts numeric fields', () {
    final seat = SeatMapSeat.fromJson({
      'id': 'seat-1',
      'seatCode': 'A01',
      'hallCode': 'H1',
      'floor': 'Level 1',
      'zone': 'Quiet Zone',
      'hasPowerOutlet': true,
      'acousticsDb': 24.8,
      'features': ['Window', 12],
      'available': true,
    });

    expect(seat.id, 'seat-1');
    expect(seat.seatCode, 'A01');
    expect(seat.acousticsDb, 24);
    expect(seat.features, ['Window', '12']);
    expect(seat.available, isTrue);
  });

  test('SeatBookingRecord.fromJson applies defaults to missing values', () {
    final booking = SeatBookingRecord.fromJson({});

    expect(booking.id, isEmpty);
    expect(booking.userId, isEmpty);
    expect(booking.seatCode, isEmpty);
    expect(booking.bookingDate, isEmpty);
    expect(booking.status, isEmpty);
    expect(booking.createdAt, isNull);
    expect(booking.checkInTime, isNull);
  });
}
