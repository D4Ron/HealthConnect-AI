class MedicalProfileModel {
  final String id;
  final String userId;
  final List<String> conditions; // ['diabetes', 'hypertension']
  final List<String> medications;
  final List<String> allergies;
  final DateTime? dateOfBirth;
  final String? bloodType;
  final String? emergencyContact;
  final String? emergencyPhone;

  MedicalProfileModel({
    required this.id,
    required this.userId,
    required this.conditions,
    required this.medications,
    required this.allergies,
    this.dateOfBirth,
    this.bloodType,
    this.emergencyContact,
    this.emergencyPhone,
  });

  factory MedicalProfileModel.fromJson(Map<String, dynamic> json) {
    return MedicalProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conditions: List<String>.from(json['conditions'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      bloodType: json['blood_type'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyPhone: json['emergency_phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'conditions': conditions,
      'medications': medications,
      'allergies': allergies,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'blood_type': bloodType,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
    };
  }
}