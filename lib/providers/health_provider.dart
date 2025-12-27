import 'package:flutter/foundation.dart';
import '../models/health_record_model.dart';
import '../models/medical_profile_model.dart';
import '../services/database_service.dart';

class HealthProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  MedicalProfileModel? _medicalProfile;
  List<HealthRecordModel> _healthRecords = [];
  HealthRecordModel? _latestRecord;
  bool _isLoading = false;
  String? _errorMessage;
  int _consecutiveStableDays = 0;

  MedicalProfileModel? get medicalProfile => _medicalProfile;
  List<HealthRecordModel> get healthRecords => _healthRecords;
  HealthRecordModel? get latestRecord => _latestRecord;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get consecutiveStableDays => _consecutiveStableDays;

  // Load Medical Profile
  Future<void> loadMedicalProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _medicalProfile = await _databaseService.getMedicalProfile(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create/Update Medical Profile
  Future<bool> saveMedicalProfile({
    required String userId,
    required List<String> conditions,
    required List<String> medications,
    required List<String> allergies,
    DateTime? dateOfBirth,
    String? bloodType,
    String? emergencyContact,
    String? emergencyPhone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_medicalProfile == null) {
        // Create new profile
        _medicalProfile = await _databaseService.createMedicalProfile(
          userId: userId,
          conditions: conditions,
          medications: medications,
          allergies: allergies,
          dateOfBirth: dateOfBirth,
          bloodType: bloodType,
          emergencyContact: emergencyContact,
          emergencyPhone: emergencyPhone,
        );
      } else {
        // Update existing profile
        _medicalProfile = await _databaseService.updateMedicalProfile(
          profileId: _medicalProfile!.id,
          conditions: conditions,
          medications: medications,
          allergies: allergies,
          dateOfBirth: dateOfBirth,
          bloodType: bloodType,
          emergencyContact: emergencyContact,
          emergencyPhone: emergencyPhone,
        );
      }

      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Submit Health Check-in
  Future<bool> submitHealthCheckIn({
    required String userId,
    Map<String, dynamic>? vitalSigns,
    Map<String, dynamic>? questionnaireResponses,
    int? riskScore,
    String? status,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final record = await _databaseService.createHealthRecord(
        userId: userId,
        vitalSigns: vitalSigns,
        questionnaireResponses: questionnaireResponses,
        riskScore: riskScore,
        status: status,
      );

      if (record != null) {
        _latestRecord = record;
        _healthRecords.insert(0, record);

        // Update consecutive stable days
        if (status == 'stable') {
          _consecutiveStableDays++;
        } else {
          _consecutiveStableDays = 0;
        }
      }

      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load Health Records
  Future<void> loadHealthRecords(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _healthRecords = await _databaseService.getHealthRecords(
        userId: userId,
        limit: 30,
      );

      if (_healthRecords.isNotEmpty) {
        _latestRecord = _healthRecords.first;
      }

      _consecutiveStableDays = await _databaseService.getConsecutiveStableDays(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}