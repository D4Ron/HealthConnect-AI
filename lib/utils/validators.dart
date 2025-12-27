class Validators {
  // Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }

    return null;
  }

  // Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }

  // Name Validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom requis';
    }

    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }

    return null;
  }

  // Phone Validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{8,}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }

    return null;
  }

  // Blood Pressure Validation
  static String? validateBloodPressure(String? value, {required bool isSystolic}) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }

    final bp = int.tryParse(value);
    if (bp == null) {
      return 'Valeur invalide';
    }

    if (isSystolic) {
      if (bp < 70 || bp > 250) {
        return 'Doit être entre 70 et 250';
      }
    } else {
      if (bp < 40 || bp > 150) {
        return 'Doit être entre 40 et 150';
      }
    }

    return null;
  }

  // Glucose Validation
  static String? validateGlucose(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }

    final glucose = int.tryParse(value);
    if (glucose == null) {
      return 'Valeur invalide';
    }

    if (glucose < 20 || glucose > 600) {
      return 'Doit être entre 20 et 600 mg/dL';
    }

    return null;
  }

  // Heart Rate Validation
  static String? validateHeartRate(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional
    }

    final hr = int.tryParse(value);
    if (hr == null) {
      return 'Valeur invalide';
    }

    if (hr < 30 || hr > 220) {
      return 'Doit être entre 30 et 220 bpm';
    }

    return null;
  }
}