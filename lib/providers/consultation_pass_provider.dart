import 'package:flutter/foundation.dart';
import '../models/consultation_pass_model.dart';
import '../models/user_model.dart';
import '../models/medical_profile_model.dart';
import '../models/health_record_model.dart';
import '../services/consultation_pass_service.dart';

class ConsultationPassProvider with ChangeNotifier {
  final ConsultationPassService _service = ConsultationPassService();

  ConsultationPassModel? _activePass;
  bool _isLoading = false;
  String? _errorMessage;
  bool _shouldShowConsultationSuggestion = false;

  ConsultationPassModel? get activePass => _activePass;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get shouldShowConsultationSuggestion => _shouldShowConsultationSuggestion;

  // Request consultation
  Future<bool> requestConsultation({
    required UserModel user,
    required MedicalProfileModel medicalProfile,
    required List<HealthRecordModel> healthHistory,
    String? reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activePass = await _service.requestConsultation(
        user: user,
        medicalProfile: medicalProfile,
        healthHistory: healthHistory,
        reason: reason,
      );

      _isLoading = false;
      notifyListeners();
      return _activePass != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load active pass
  Future<void> loadActivePass(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activePass = await _service.getActivePass(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check if consultation should be triggered
  Future<void> checkConsultationNeed(String userId) async {
    try {
      final recentRecords = await _service.getRecentRecordsForAnalysis(userId);
      _shouldShowConsultationSuggestion =
          _service.shouldTriggerConsultation(recentRecords);
      notifyListeners();
    } catch (e) {
      print('Check consultation need error: $e');
    }
  }

  // Dismiss suggestion
  void dismissConsultationSuggestion() {
    _shouldShowConsultationSuggestion = false;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear active pass
  void clearActivePass() {
    _activePass = null;
    notifyListeners();
  }
}