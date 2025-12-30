class ConsultationPassModel {
  final String id;
  final String userId;
  final String passId;
  final String numericCode;
  final String? qrCodeUrl; // Changed from qrCodeData to qrCodeUrl
  final Map<String, dynamic> clinicalSummary;
  final String? facilityId;
  final String? facilityName;
  final String? facilityAddress;
  final String? assignedDepartment;
  final double? facilityLatitude;
  final double? facilityLongitude;
  final int? estimatedWaitTime;
  final String status;
  final DateTime generatedAt;
  final DateTime validUntil;
  final DateTime? arrivalConfirmedAt;

  ConsultationPassModel({
    required this.id,
    required this.userId,
    required this.passId,
    required this.numericCode,
    this.qrCodeUrl,
    required this.clinicalSummary,
    this.facilityId,
    this.facilityName,
    this.facilityAddress,
    this.assignedDepartment,
    this.facilityLatitude,
    this.facilityLongitude,
    this.estimatedWaitTime,
    required this.status,
    required this.generatedAt,
    required this.validUntil,
    this.arrivalConfirmedAt,
  });

  factory ConsultationPassModel.fromJson(Map<String, dynamic> json) {
    return ConsultationPassModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      passId: json['pass_id']?.toString() ?? json['id'].toString(),
      numericCode: json['numeric_code']?.toString() ?? '',
      qrCodeUrl: json['qr_code_url'] as String?,
      clinicalSummary: json['clinical_summary'] as Map<String, dynamic>? ?? {},
      facilityId: json['facility_id']?.toString(),
      facilityName: json['facility_name'] as String?,
      facilityAddress: json['facility_address'] as String?,
      assignedDepartment: json['assigned_department'] as String?,
      facilityLatitude: json['facility_latitude']?.toDouble(),
      facilityLongitude: json['facility_longitude']?.toDouble(),
      estimatedWaitTime: json['estimated_wait_time'] as int?,
      status: json['status'] as String? ?? 'pending',
      generatedAt: json['generated_at'] != null
          ? DateTime.parse(json['generated_at'] as String)
          : DateTime.now(),
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : DateTime.now().add(const Duration(hours: 48)),
      arrivalConfirmedAt: json['arrival_confirmed_at'] != null
          ? DateTime.parse(json['arrival_confirmed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pass_id': passId,
      'numeric_code': numericCode,
      'qr_code_url': qrCodeUrl,
      'clinical_summary': clinicalSummary,
      'facility_id': facilityId,
      'facility_name': facilityName,
      'facility_address': facilityAddress,
      'assigned_department': assignedDepartment,
      'facility_latitude': facilityLatitude,
      'facility_longitude': facilityLongitude,
      'estimated_wait_time': estimatedWaitTime,
      'status': status,
      'generated_at': generatedAt.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'arrival_confirmed_at': arrivalConfirmedAt?.toIso8601String(),
    };
  }

  bool get isValid {
    return DateTime.now().isBefore(validUntil) && status != 'expired';
  }

  bool get isActive {
    return status == 'active' || status == 'pending';
  }
}