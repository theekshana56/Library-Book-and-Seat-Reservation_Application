class AdminUser {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String department;
  final String userCategory;
  final bool active;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.department,
    required this.userCategory,
    required this.active,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    role: json['role']?.toString() ?? 'STUDENT',
    department: json['department']?.toString() ?? '',
    userCategory: json['userCategory']?.toString() ?? '',
    active: json['active'] == true,
  );
}

class PublisherProposal {
  final String id;
  final String vendorId;
  final String vendorName;
  final String bookTitle;
  final String author;
  final String isbn;
  final String category;
  final String description;
  final double proposedPrice;
  final int vendorSupplyQty;
  final int adminRequestedLotQty;
  final String adminMessage;
  final String sampleCoverImageUrl;
  final String status;

  const PublisherProposal({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.bookTitle,
    required this.author,
    required this.isbn,
    required this.category,
    required this.description,
    required this.proposedPrice,
    required this.vendorSupplyQty,
    required this.adminRequestedLotQty,
    required this.adminMessage,
    required this.sampleCoverImageUrl,
    required this.status,
  });

  factory PublisherProposal.fromJson(Map<String, dynamic> json) =>
      PublisherProposal(
        id: json['id']?.toString() ?? '',
        vendorId: json['vendorId']?.toString() ?? '',
        vendorName: json['vendorName']?.toString() ?? '',
        bookTitle: json['bookTitle']?.toString() ?? '',
        author: json['author']?.toString() ?? '',
        isbn: json['isbn']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        proposedPrice: (json['proposedPrice'] as num?)?.toDouble() ?? 0,
        vendorSupplyQty: (json['vendorSupplyQty'] as num?)?.toInt() ?? 0,
        adminRequestedLotQty:
            (json['adminRequestedLotQty'] as num?)?.toInt() ?? 0,
        adminMessage: json['adminMessage']?.toString() ?? '',
        sampleCoverImageUrl: json['sampleCoverImageUrl']?.toString() ?? '',
        status: json['status']?.toString() ?? 'PENDING_ADMIN_REVIEW',
      );
}

class StaffTask {
  final String id;
  final String assignedStaffId;
  final String assignedStaffName;
  final String bookId;
  final String bookTitle;
  final String taskDescription;
  final String targetShelfCode;
  final int quantity;
  final String status;

  const StaffTask({
    required this.id,
    required this.assignedStaffId,
    required this.assignedStaffName,
    required this.bookId,
    required this.bookTitle,
    required this.taskDescription,
    required this.targetShelfCode,
    required this.quantity,
    required this.status,
  });

  factory StaffTask.fromJson(Map<String, dynamic> json) => StaffTask(
    id: json['id']?.toString() ?? '',
    assignedStaffId: json['assignedStaffId']?.toString() ?? '',
    assignedStaffName: json['assignedStaffName']?.toString() ?? '',
    bookId: json['bookId']?.toString() ?? '',
    bookTitle: json['bookTitle']?.toString() ?? '',
    taskDescription: json['taskDescription']?.toString() ?? '',
    targetShelfCode: json['targetShelfCode']?.toString() ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    status: json['status']?.toString() ?? 'PENDING',
  );
}

class LibraryShelf {
  final String id;
  final String shelfCode;
  final String level;
  final String zone;
  final int maxCapacity;
  final int currentBookCount;

  const LibraryShelf({
    required this.id,
    required this.shelfCode,
    required this.level,
    required this.zone,
    required this.maxCapacity,
    required this.currentBookCount,
  });

  factory LibraryShelf.fromJson(Map<String, dynamic> json) => LibraryShelf(
    id: json['id']?.toString() ?? '',
    shelfCode: json['shelfCode']?.toString() ?? '',
    level: json['level']?.toString() ?? '',
    zone: json['zone']?.toString() ?? '',
    maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 0,
    currentBookCount: (json['currentBookCount'] as num?)?.toInt() ?? 0,
  );
}

class LibraryHall {
  final String id;
  final String hallCode;
  final String name;
  final String building;
  final int floorCount;
  final String description;

  const LibraryHall({
    required this.id,
    required this.hallCode,
    required this.name,
    required this.building,
    required this.floorCount,
    required this.description,
  });

  factory LibraryHall.fromJson(Map<String, dynamic> json) => LibraryHall(
    id: json['id']?.toString() ?? '',
    hallCode: json['hallCode']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    building: json['building']?.toString() ?? '',
    floorCount: (json['floorCount'] as num?)?.toInt() ?? 1,
    description: json['description']?.toString() ?? '',
  );
}

class LibrarySeat {
  final String id;
  final String seatCode;
  final String hallCode;
  final String floor;
  final String zone;
  final bool hasPowerOutlet;
  final int acousticsDb;
  final List<String> features;

  const LibrarySeat({
    required this.id,
    required this.seatCode,
    required this.hallCode,
    required this.floor,
    required this.zone,
    required this.hasPowerOutlet,
    required this.acousticsDb,
    required this.features,
  });

  factory LibrarySeat.fromJson(Map<String, dynamic> json) => LibrarySeat(
    id: json['id']?.toString() ?? '',
    seatCode: json['seatCode']?.toString() ?? '',
    hallCode: json['hallCode']?.toString() ?? '',
    floor: json['floor']?.toString() ?? '',
    zone: json['zone']?.toString() ?? '',
    hasPowerOutlet: json['hasPowerOutlet'] == true,
    acousticsDb: (json['acousticsDb'] as num?)?.toInt() ?? 0,
    features: (json['features'] as List<dynamic>? ?? const [])
        .map((feature) => feature.toString())
        .toList(),
  );
}

class AdminStats {
  final int totalRegisteredUsers;
  final int activeStaffTasks;
  final int pendingPublisherProposals;
  final int totalShelfCapacity;
  final int activeUsers;

  const AdminStats({
    required this.totalRegisteredUsers,
    required this.activeStaffTasks,
    required this.pendingPublisherProposals,
    required this.totalShelfCapacity,
    required this.activeUsers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalRegisteredUsers: (json['totalRegisteredUsers'] as num?)?.toInt() ?? 0,
    activeStaffTasks: (json['activeStaffTasks'] as num?)?.toInt() ?? 0,
    pendingPublisherProposals:
        (json['pendingPublisherProposals'] as num?)?.toInt() ?? 0,
    totalShelfCapacity: (json['totalShelfCapacity'] as num?)?.toInt() ?? 0,
    activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
  );
}
