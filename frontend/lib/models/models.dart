class Reservation {
  final String id;
  final String holdIdCode;
  final String userId;
  final String borrowerLabel;
  final String studentCardId;
  final String department;
  final String bookId;
  final String title;
  final String author;
  final String coverImageUrl;
  final String shelfCode;
  final String shelfDetail;
  final String format;
  final bool priorityHold;
  final String pickupDesk;
  final String pickupDeskDetail;
  final String status;
  final DateTime createdAt;
  final DateTime expiresAt;

  const Reservation({
    required this.id,
    required this.holdIdCode,
    required this.userId,
    required this.borrowerLabel,
    required this.studentCardId,
    required this.department,
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.shelfCode,
    required this.shelfDetail,
    required this.format,
    required this.priorityHold,
    required this.pickupDesk,
    required this.pickupDeskDetail,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id']?.toString() ?? '',
      holdIdCode: json['holdIdCode'] ?? '',
      userId: json['userId'] ?? '',
      borrowerLabel: json['borrowerLabel'] ?? '',
      studentCardId: json['studentCardId'] ?? '2024-9182',
      department: json['department'] ?? 'CS Dept',
      bookId: json['bookId'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      shelfCode: json['shelfCode'] ?? '',
      shelfDetail: json['shelfDetail'] ?? '',
      format: json['format'] ?? 'Print Copy',
      priorityHold: json['priorityHold'] == true,
      pickupDesk: json['pickupDesk'] ?? 'Central Circulation Desk',
      pickupDeskDetail: json['pickupDeskDetail'] ?? 'Level 1 • East Atrium Entrance',
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
          DateTime.now().add(const Duration(hours: 24)),
    );
  }
}

class SeatHold {
  final String id;
  final String seatCode;
  final String seatName;
  final String zone;
  final String slotLabel;
  final List<String> amenities;
  final DateTime checkInBy;
  final String status;

  const SeatHold({
    required this.id,
    required this.seatCode,
    required this.seatName,
    required this.zone,
    required this.slotLabel,
    required this.amenities,
    required this.checkInBy,
    required this.status,
  });

  factory SeatHold.fromJson(Map<String, dynamic> json) {
    return SeatHold(
      id: json['id']?.toString() ?? '',
      seatCode: json['seatCode'] ?? '',
      seatName: json['seatName'] ?? '',
      zone: json['zone'] ?? '',
      slotLabel: json['slotLabel'] ?? '',
      amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      checkInBy: DateTime.tryParse(json['checkInBy']?.toString() ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}

class Loan {
  final String id;
  final String title;
  final String author;
  final String coverImageUrl;
  final DateTime borrowedAt;
  final DateTime dueDate;
  final int renewCount;
  final int loanLimit;
  final String status;

  const Loan({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImageUrl,
    required this.borrowedAt,
    required this.dueDate,
    required this.renewCount,
    required this.loanLimit,
    required this.status,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? '',
      borrowedAt: DateTime.tryParse(json['borrowedAt']?.toString() ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? '') ?? DateTime.now(),
      renewCount: json['renewCount'] ?? 0,
      loanLimit: json['loanLimit'] ?? 5,
      status: json['status'] ?? 'ACTIVE',
    );
  }
}

class UserBookings {
  final String userId;
  final int activeCount;
  final int historyCount;
  final int loanLimit;
  final List<Reservation> reservations;
  final List<SeatHold> seatHolds;
  final List<Loan> loans;

  const UserBookings({
    required this.userId,
    required this.activeCount,
    required this.historyCount,
    required this.loanLimit,
    required this.reservations,
    required this.seatHolds,
    required this.loans,
  });

  factory UserBookings.fromJson(Map<String, dynamic> json) {
    return UserBookings(
      userId: json['userId'] ?? '',
      activeCount: json['activeCount'] ?? 0,
      historyCount: json['historyCount'] ?? 0,
      loanLimit: json['loanLimit'] ?? 5,
      reservations: (json['reservations'] as List? ?? [])
          .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
          .toList(),
      seatHolds: (json['seatHolds'] as List? ?? [])
          .map((e) => SeatHold.fromJson(e as Map<String, dynamic>))
          .toList(),
      loans: (json['loans'] as List? ?? [])
          .map((e) => Loan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
