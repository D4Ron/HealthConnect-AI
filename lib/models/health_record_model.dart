class HealthRecordModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? vitalSigns;
  final Map<String, dynamic>? questionnaireResponses;
  final int? riskScore;
  final String? status; // 'stable', 'moderate', 'urgent', 'critical'

  HealthRecordModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    this.vitalSigns,
    this.questionnaireResponses,
    this.riskScore,
    this.status,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    return HealthRecordModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      vitalSigns: json['vital_signs'] as Map<String, dynamic>?,
      questionnaireResponses: json['questionnaire_responses'] as Map<String, dynamic>?,
      riskScore: json['risk_score'] as int?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'timestamp': timestamp.toIso8601String(),
      'vital_signs': vitalSigns,
      'questionnaire_responses': questionnaireResponses,
      'risk_score': riskScore,
      'status': status,
    };
  }
}