import 'package:biblione/models/models.dart';
import 'package:biblione/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Reservation.fromJson', () {
    test('parses a successful book reservation response', () {
      final reservation = Reservation.fromJson({
        'id': 'reservation-1',
        'holdIdCode': 'BBL-123-DDIA',
        'userId': 'IT23773158',
        'borrowerLabel': 'Theekshana',
        'studentCardId': 'IT23773158',
        'department': 'Computer Science',
        'bookId': 'book-ddia',
        'title': 'Designing Data-Intensive Applications',
        'author': 'Martin Kleppmann',
        'shelfCode': 'CS-204',
        'status': 'READY_FOR_PICKUP',
        'createdAt': '2026-10-12T08:00:00Z',
        'expiresAt': '2026-10-13T08:00:00Z',
        'loanPeriodDays': 14,
        'priorityHold': true,
      });

      expect(reservation.id, 'reservation-1');
      expect(reservation.holdIdCode, 'BBL-123-DDIA');
      expect(reservation.bookId, 'book-ddia');
      expect(reservation.title, 'Designing Data-Intensive Applications');
      expect(reservation.status, 'READY_FOR_PICKUP');
      expect(reservation.loanPeriodDays, 14);
      expect(reservation.priorityHold, isTrue);
      expect(reservation.expiresAt, DateTime.utc(2026, 10, 13, 8));
    });

    test('uses safe reservation defaults for incomplete responses', () {
      final reservation = Reservation.fromJson({});

      expect(reservation.id, isEmpty);
      expect(reservation.holdIdCode, isEmpty);
      expect(reservation.userId, isEmpty);
      expect(reservation.studentCardId, '2024-9182');
      expect(reservation.department, 'CS Dept');
      expect(reservation.format, 'Print Copy');
      expect(reservation.pickupDesk, 'Central Circulation Desk');
      expect(reservation.status, isEmpty);
      expect(reservation.loanPeriodDays, 14);
    });
  });

  group('Book reservation availability', () {
    final baseBook = Book.fromJson({
      'id': 'book-1',
      'title': 'Library Book',
      'shelfCode': 'CS-101',
      'shelfDetail': 'Row A',
      'availableCopies': 2,
      'totalCopies': 3,
    });

    test('allows reservation when a shelved copy is available', () {
      expect(baseBook.isAvailable, isTrue);
      expect(baseBook.copiesLabel, '2 Copies');
    });

    test('prevents reservation when no copies or shelving is pending', () {
      final unavailable = Book.fromJson({
        'availableCopies': 0,
        'shelfCode': 'CS-101',
        'nextReturnDate': '2026-10-20',
      });
      final pending = Book.fromJson({
        'availableCopies': 2,
        'shelfCode': 'CS-101',
        'inventoryStatus': 'PENDING_SHELVING',
      });

      expect(unavailable.isAvailable, isFalse);
      expect(unavailable.copiesLabel, 'Due Oct 20');
      expect(pending.isAvailable, isFalse);
    });
  });
}
