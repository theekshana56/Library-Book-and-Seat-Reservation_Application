class SeatSearchRequest {
  final DateTime date;
  final String startTime;
  final int durationMinutes;
  final String zonePreference;
  final bool? powerRequired;

  const SeatSearchRequest({
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.zonePreference,
    required this.powerRequired,
  });

  Map<String, dynamic> toJson() => {
    'date':
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}',
    'startTime': startTime,
    'durationMinutes': durationMinutes,
    'zonePreference': zonePreference,
    'powerRequired': powerRequired,
  };
}

class SeatMatch {
  final String id;
  final String seatCode;
  final String floor;
  final String zone;
  final bool hasPowerOutlet;
  final int acousticsDb;
  final List<String> features;
  final int matchScore;

  const SeatMatch({
    required this.id,
    required this.seatCode,
    required this.floor,
    required this.zone,
    required this.hasPowerOutlet,
    required this.acousticsDb,
    required this.features,
    required this.matchScore,
  });

  factory SeatMatch.fromJson(Map<String, dynamic> json) => SeatMatch(
    id: json['id']?.toString() ?? '',
    seatCode: json['seatCode']?.toString() ?? 'Unknown',
    floor: json['floor']?.toString() ?? 'Library floor',
    zone: json['zone']?.toString() ?? 'General Zone',
    hasPowerOutlet: json['hasPowerOutlet'] == true,
    acousticsDb: (json['acousticsDb'] as num?)?.toInt() ?? 0,
    features: (json['features'] as List<dynamic>? ?? const [])
        .map((value) => value.toString())
        .toList(),
    matchScore: (json['matchScore'] as num?)?.toInt() ?? 0,
  );
}

class SeatRecommendationResponse {
  final List<SeatMatch> exactMatches;
  final List<SeatMatch> closestMatches;

  const SeatRecommendationResponse({
    required this.exactMatches,
    required this.closestMatches,
  });

  factory SeatRecommendationResponse.fromJson(Map<String, dynamic> json) =>
      SeatRecommendationResponse(
        exactMatches: _readMatches(json['exactMatches']),
        closestMatches: _readMatches(json['closestMatches']),
      );

  static List<SeatMatch> _readMatches(dynamic value) =>
      (value as List<dynamic>? ?? const [])
          .map((item) => SeatMatch.fromJson(item as Map<String, dynamic>))
          .toList();
}
