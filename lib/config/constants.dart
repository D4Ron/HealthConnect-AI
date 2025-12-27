class AppConstants {
  // App Info
  static const String appName = 'HealthConnect AI';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';

  // Database Tables
  static const String tableUsers = 'users';
  static const String tableHealthRecords = 'health_records';
  static const String tableMedicalProfiles = 'medical_profiles';
  static const String tableSymptoms = 'symptoms';
  static const String tableAlerts = 'alerts';
  static const String tableEmergencyPasses = 'emergency_passes';

  // Django API Configuration
  static const String djangoApiBaseUrl = 'YOUR_DJANGO_API_URL'; // e.g., 'https://api.yourdomain.com'
  static const String consultationRequestEndpoint = '/api/consultation-request/';

  // Consultation Pass Settings
  static const int consultationPassValidityHours = 48;
  static const int healthHistoryDays = 30;
}