class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final String edition;
  final int year;
  final String category;
  final String callNumber;
  final String format;
  final String shelfCode;
  final String shelfDetail;
  final String wayfinding;
  final String pickupDesk;
  final String pickupDeskDetail;
  final int loanPeriodDays;
  final int totalCopies;
  final int availableCopies;
  final int waitlistCount;
  final String? inventoryStatus;
  final DateTime? nextReturnDate;
  final String? currentBorrower;
  final String coverImageUrl;
  final String? isbn;
  final String? description;
  final String? catalogNotice;
  final int? expressHoldHours;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.edition,
    required this.year,
    required this.category,
    required this.callNumber,
    required this.format,
    required this.shelfCode,
    required this.shelfDetail,
    required this.wayfinding,
    required this.pickupDesk,
    required this.pickupDeskDetail,
    required this.loanPeriodDays,
    required this.totalCopies,
    required this.availableCopies,
    required this.waitlistCount,
    this.inventoryStatus,
    this.nextReturnDate,
    this.currentBorrower,
    required this.coverImageUrl,
    this.isbn,
    this.description,
    this.catalogNotice,
    this.expressHoldHours,
  });

  bool get isAvailable =>
      availableCopies > 0 &&
      inventoryStatus != 'PENDING_SHELVING' &&
      shelfCode.trim().isNotEmpty;

  String get shelfLabel => 'Shelf $shelfCode • $shelfDetail';

  String get copiesLabel {
    if (availableCopies <= 0) return 'Due ${_dueShort()}';
    if (availableCopies == 1) return '1 Copy on Shelf';
    return '$availableCopies Copies';
  }

  String _dueShort() {
    final d = nextReturnDate;
    if (d == null) return 'soon';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      edition: json['edition'] ?? '',
      year: json['year'] ?? 0,
      category: json['category'] ?? '',
      callNumber: json['callNumber'] ?? '',
      format: json['format'] ?? 'Print Copy',
      shelfCode: json['shelfCode'] ?? '',
      shelfDetail: json['shelfDetail'] ?? '',
      wayfinding: json['wayfinding'] ?? '',
      pickupDesk: json['pickupDesk'] ?? 'Central Circulation Desk',
      pickupDeskDetail:
          json['pickupDeskDetail'] ?? 'Level 1, East Atrium Entrance',
      loanPeriodDays: json['loanPeriodDays'] ?? 14,
      totalCopies: json['totalCopies'] ?? 0,
      availableCopies: json['availableCopies'] ?? 0,
      waitlistCount: json['waitlistCount'] ?? 0,
      inventoryStatus: json['inventoryStatus']?.toString(),
      nextReturnDate: json['nextReturnDate'] != null
          ? DateTime.tryParse(json['nextReturnDate'].toString())
          : null,
      currentBorrower: json['currentBorrower'],
      coverImageUrl: json['coverImageUrl'] ?? '',
      isbn: json['isbn']?.toString(),
      description: json['description']?.toString(),
      catalogNotice: json['catalogNotice'],
      expressHoldHours: json['expressHoldHours'],
    );
  }
}
