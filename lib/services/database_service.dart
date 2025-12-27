import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../config/constants.dart';
import '../models/health_record_model.dart';
import '../models/medical_profile_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ==================== MEDICAL PROFILE ====================

  // Create Medical Profile
  Future<MedicalProfileModel?> createMedicalProfile({
    required String userId,
    required List<String> conditions,
    required List<String> medications,
    required List<String> allergies,
    DateTime? dateOfBirth,
    String? bloodType,
    String? emergencyContact,
    String? emergencyPhone,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'conditions': conditions,
        'medications': medications,
        'allergies': allergies,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'blood_type': bloodType,
        'emergency_contact': emergencyContact,
        'emergency_phone': emergencyPhone,
      };

      final response = await _supabase
          .from(AppConstants.tableMedicalProfiles)
          .insert(data)
          .select()
          .single();

      return MedicalProfileModel.fromJson(response);
    } catch (e) {
      print('Create medical profile error: $e');
      rethrow;
    }
  }

  // Get Medical Profile
  Future<MedicalProfileModel?> getMedicalProfile(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableMedicalProfiles)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return MedicalProfileModel.fromJson(response);
    } catch (e) {
      print('Get medical profile error: $e');
      return null;
    }
  }

  // Update Medical Profile
  Future<MedicalProfileModel?> updateMedicalProfile({
    required String profileId,
    List<String>? conditions,
    List<String>? medications,
    List<String>? allergies,
    DateTime? dateOfBirth,
    String? bloodType,
    String? emergencyContact,
    String? emergencyPhone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (conditions != null) data['conditions'] = conditions;
      if (medications != null) data['medications'] = medications;
      if (allergies != null) data['allergies'] = allergies;
      if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth.toIso8601String();
      if (bloodType != null) data['blood_type'] = bloodType;
      if (emergencyContact != null) data['emergency_contact'] = emergencyContact;
      if (emergencyPhone != null) data['emergency_phone'] = emergencyPhone;

      final response = await _supabase
          .from(AppConstants.tableMedicalProfiles)
          .update(data)
          .eq('id', profileId)
          .select()
          .single();

      return MedicalProfileModel.fromJson(response);
    } catch (e) {
      print('Update medical profile error: $e');
      rethrow;
    }
  }

  // ==================== HEALTH RECORDS ====================

  // Create Health Record
  Future<HealthRecordModel?> createHealthRecord({
    required String userId,
    Map<String, dynamic>? vitalSigns,
    Map<String, dynamic>? questionnaireResponses,
    int? riskScore,
    String? status,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
        'vital_signs': vitalSigns,
        'questionnaire_responses': questionnaireResponses,
        'risk_score': riskScore,
        'status': status,
      };

      final response = await _supabase
          .from(AppConstants.tableHealthRecords)
          .insert(data)
          .select()
          .single();

      return HealthRecordModel.fromJson(response);
    } catch (e) {
      print('Create health record error: $e');
      rethrow;
    }
  }

  // Get Recent Health Records
  Future<List<HealthRecordModel>> getHealthRecords({
    required String userId,
    int limit = 30,
  }) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableHealthRecords)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => HealthRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get health records error: $e');
      return [];
    }
  }

  // Get Latest Health Record
  Future<HealthRecordModel?> getLatestHealthRecord(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableHealthRecords)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return HealthRecordModel.fromJson(response);
    } catch (e) {
      print('Get latest health record error: $e');
      return null;
    }
  }

  // Get Health Records by Date Range
  Future<List<HealthRecordModel>> getHealthRecordsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableHealthRecords)
          .select()
          .eq('user_id', userId)
          .gte('timestamp', startDate.toIso8601String())
          .lte('timestamp', endDate.toIso8601String())
          .order('timestamp', ascending: false);

      return (response as List)
          .map((json) => HealthRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get health records by date range error: $e');
      return [];
    }
  }

  // Count consecutive stable days
  Future<int> getConsecutiveStableDays(String userId) async {
    try {
      final records = await getHealthRecords(userId: userId, limit: 30);

      int consecutiveDays = 0;
      for (var record in records) {
        if (record.status == 'stable') {
          consecutiveDays++;
        } else {
          break;
        }
      }

      return consecutiveDays;
    } catch (e) {
      print('Get consecutive stable days error: $e');
      return 0;
    }
  }
}