import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../config/constants.dart';
import '../config/supabase_config.dart';
import '../models/consultation_pass_model.dart';
import '../models/user_model.dart';
import '../models/medical_profile_model.dart';
import '../models/health_record_model.dart';

class ConsultationPassService {
  final _supabase = SupabaseConfig.client;

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

      // Calculate age from date of birth
      int? age;
      if (medicalProfile.dateOfBirth != null) {
        age = DateTime.now().year - medicalProfile.dateOfBirth!.year;
      }

      // Create multipart request instead of JSON
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '${AppConstants.djangoApiBaseUrl}${AppConstants.consultationRequestEndpoint}',
        ),
      );

      // Add text fields
      request.fields['patient_first_name'] = user.firstName ?? '';
      request.fields['patient_last_name'] = user.lastName ?? '';
      request.fields['patient_email'] = user.email;
      if (age != null) {
        request.fields['age'] = age.toString();
      }

      // Add complex data as JSON strings
      request.fields['medical_profile'] = jsonEncode({
        'conditions': medicalProfile.conditions,
        'medications': medicalProfile.medications,
        'allergies': medicalProfile.allergies,
        'blood_type': medicalProfile.bloodType,
        'emergency_contact': medicalProfile.emergencyContact,
        'emergency_phone': medicalProfile.emergencyPhone,
      });

      request.fields['health_history'] = jsonEncode(healthHistory.map((record) {
        return {
          'timestamp': record.timestamp.toIso8601String(),
          'vital_signs': record.vitalSigns,
          'risk_score': record.riskScore,
          'status': record.status,
        };
      }).toList());

      request.fields['clinical_summary'] = jsonEncode(clinicalSummary);

      if (reason != null) {
        request.fields['request_reason'] = reason;
      }

      request.fields['requested_at'] = DateTime.now().toIso8601String();

      print('Sending multipart request to: ${request.url}');
      print('Fields: ${request.fields}');

      // Send request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout - Please check your server');
        },
      );

      // Get response
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Save to Supabase with data from Django
        final passData = {
          'user_id': user.id,
          'pass_id': data['id'].toString(),
          'numeric_code': data['id'].toString(),
          'qr_code': data['qr_code_url'],
          'clinical_summary': clinicalSummary,
          'facility_id': null,
          'facility_name': null,
          'facility_address': null,
          'assigned_department': null,
          'facility_latitude': null,
          'facility_longitude': null,
          'estimated_wait_time': null,
          'status': 'pending',
          'generated_at': DateTime.now().toIso8601String(),
          'valid_until': DateTime.now()
              .add(Duration(hours: AppConstants.consultationPassValidityHours))
              .toIso8601String(),
        };

        try {
          final savedPass = await _supabase
              .from(AppConstants.tableEmergencyPasses)
              .insert(passData)
              .select()
              .single();

          return ConsultationPassModel.fromJson({
            ...savedPass,
            'qr_code_url': data['qr_code_url'],
          });
        } catch (supabaseError) {
          print('Supabase error: $supabaseError');
          return ConsultationPassModel.fromJson({
            'id': data['id'].toString(),
            'user_id': user.id,
            'pass_id': data['id'].toString(),
            'numeric_code': data['id'].toString(),
            'qr_code_url': data['qr_code_url'],
            'clinical_summary': clinicalSummary,
            'status': 'pending',
            'generated_at': DateTime.now().toIso8601String(),
            'valid_until': DateTime.now()
                .add(Duration(hours: AppConstants.consultationPassValidityHours))
                .toIso8601String(),
          });
        }
      } else {
        throw Exception('Django API Error: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error - Please check your internet connection and server');
    } on FormatException {
      throw Exception('Invalid response format from server');
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