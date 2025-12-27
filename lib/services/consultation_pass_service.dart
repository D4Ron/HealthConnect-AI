import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../config/supabase_config.dart';
import '../models/consultation_pass_model.dart';
import '../models/user_model.dart';
import '../models/medical_profile_model.dart';
import '../models/health_record_model.dart';

class ConsultationPassService {
  final _supabase = SupabaseConfig.client;

  // Generate consultation pass via Django API
  Future<ConsultationPassModel?> requestConsultation({
    required UserModel user,
    required MedicalProfileModel medicalProfile,
    required List<HealthRecordModel> healthHistory,
    String? reason,
  }) async {
    try {
      // Prepare clinical summary
      final clinicalSummary = _prepareClinicalSummary(
        user: user,
        medicalProfile: medicalProfile,
        healthHistory: healthHistory,
        reason: reason,
      );

      // Call Django API
      final response = await http.post(
        Uri.parse(
          '${AppConstants.djangoApiBaseUrl}${AppConstants.consultationRequestEndpoint}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'patient_data': {
            'user_id': user.id,
            'email': user.email,
            'first_name': user.firstName,
            'last_name': user.lastName,
          },
          'medical_profile': {
            'conditions': medicalProfile.conditions,
            'medications': medicalProfile.medications,
            'allergies': medicalProfile.allergies,
            'blood_type': medicalProfile.bloodType,
            'emergency_contact': medicalProfile.emergencyContact,
            'emergency_phone': medicalProfile.emergencyPhone,
          },
          'health_history': healthHistory.map((record) {
            return {
              'timestamp': record.timestamp.toIso8601String(),
              'vital_signs': record.vitalSigns,
              'risk_score': record.riskScore,
              'status': record.status,
            };
          }).toList(),
          'clinical_summary': clinicalSummary,
          'request_reason': reason,
          'requested_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Save to Supabase
        final passData = {
          'user_id': user.id,
          'pass_id': data['pass_id'],
          'numeric_code': data['numeric_code'],
          'qr_code': data['qr_code'],
          'clinical_summary': clinicalSummary,
          'facility_id': data['facility_id'],
          'facility_name': data['facility_name'],
          'facility_address': data['facility_address'],
          'assigned_department': data['assigned_department'],
          'facility_latitude': data['facility_latitude'],
          'facility_longitude': data['facility_longitude'],
          'estimated_wait_time': data['estimated_wait_time'],
          'status': 'pending',
          'generated_at': DateTime.now().toIso8601String(),
          'valid_until': DateTime.now()
              .add(Duration(hours: AppConstants.consultationPassValidityHours))
              .toIso8601String(),
        };

        final savedPass = await _supabase
            .from(AppConstants.tableEmergencyPasses)
            .insert(passData)
            .select()
            .single();

        return ConsultationPassModel.fromJson(savedPass);
      } else {
        throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Request consultation error: $e');
      rethrow;
    }
  }

  // Prepare clinical summary
  Map<String, dynamic> _prepareClinicalSummary({
    required UserModel user,
    required MedicalProfileModel medicalProfile,
    required List<HealthRecordModel> healthHistory,
    String? reason,
  }) {
    // Calculate trends
    final recentRecords = healthHistory.take(7).toList();
    final statusCounts = <String, int>{};

    for (var record in recentRecords) {
      statusCounts[record.status ?? 'unknown'] =
          (statusCounts[record.status ?? 'unknown'] ?? 0) + 1;
    }

    // Get latest vital signs
    final latestVitals = healthHistory.isNotEmpty
        ? healthHistory.first.vitalSigns
        : null;

    // Calculate average risk score
    final riskScores = healthHistory
        .where((r) => r.riskScore != null)
        .map((r) => r.riskScore!)
        .toList();

    final avgRiskScore = riskScores.isNotEmpty
        ? riskScores.reduce((a, b) => a + b) / riskScores.length
        : 0;

    return {
      'patient_info': {
        'name': user.fullName,
        'age': medicalProfile.dateOfBirth != null
            ? DateTime.now().year - medicalProfile.dateOfBirth!.year
            : null,
        'conditions': medicalProfile.conditions,
        'medications': medicalProfile.medications,
        'allergies': medicalProfile.allergies,
      },
      'current_status': {
        'latest_status': healthHistory.isNotEmpty
            ? healthHistory.first.status
            : 'unknown',
        'latest_risk_score': healthHistory.isNotEmpty
            ? healthHistory.first.riskScore
            : null,
        'latest_vitals': latestVitals,
      },
      'trends_7_days': {
        'status_distribution': statusCounts,
        'average_risk_score': avgRiskScore.round(),
        'total_records': recentRecords.length,
      },
      'reason_for_consultation': reason,
      'summary_generated_at': DateTime.now().toIso8601String(),
    };
  }

  // Get active consultation pass
  Future<ConsultationPassModel?> getActivePass(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableEmergencyPasses)
          .select()
          .eq('user_id', userId)
          .eq('status', 'pending')
          .order('generated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final pass = ConsultationPassModel.fromJson(response);

      // Check if expired
      if (!pass.isValid) {
        await _supabase
            .from(AppConstants.tableEmergencyPasses)
            .update({'status': 'expired'})
            .eq('id', pass.id);
        return null;
      }

      return pass;
    } catch (e) {
      print('Get active pass error: $e');
      return null;
    }
  }

  // Check if consultation is needed (declining health logic)
  bool shouldTriggerConsultation(List<HealthRecordModel> recentRecords) {
    if (recentRecords.length < 3) return false;

    // Check last 3 consecutive days
    final last3 = recentRecords.take(3).toList();

    // Define status severity
    final statusSeverity = {
      'stable': 1,
      'moderate': 2,
      'urgent': 3,
      'critical': 4,
    };

    // Check for declining trend
    for (int i = 0; i < last3.length - 1; i++) {
      final current = statusSeverity[last3[i].status] ?? 0;
      final next = statusSeverity[last3[i + 1].status] ?? 0;

      if (current <= next) {
        return false; // Not consistently declining
      }
    }

    // If we reach here, health is declining for 3 consecutive days
    return true;
  }

  // Get recent health records for analysis
  Future<List<HealthRecordModel>> getRecentRecordsForAnalysis(String userId) async {
    try {
      final response = await _supabase
          .from(AppConstants.tableHealthRecords)
          .select()
          .eq('user_id', userId)
          .order('timestamp', ascending: false)
          .limit(3);

      return (response as List)
          .map((json) => HealthRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Get recent records error: $e');
      return [];
    }
  }
}