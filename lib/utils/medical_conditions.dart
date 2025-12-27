class MedicalConditions {
  static const List<String> commonConditions = [
    'Diabète Type 1',
    'Diabète Type 2',
    'Hypertension (HTA)',
    'Asthme',
    'Maladie Cardiovasculaire',
    'Hyperlipidémie',
    'Insuffisance Cardiaque',
    'BPCO',
    'Insuffisance Rénale',
    'Hypothyroïdie',
    'Hyperthyroïdie',
    'Arthrite',
    'Autre',
  ];

  static const List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Inconnu',
  ];

  static String getConditionEmoji(String condition) {
    if (condition.toLowerCase().contains('diabète') ||
        condition.toLowerCase().contains('diabetes')) {
      return '🩸';
    } else if (condition.toLowerCase().contains('hypertension') ||
        condition.toLowerCase().contains('hta')) {
      return '🩺';
    } else if (condition.toLowerCase().contains('asthme') ||
        condition.toLowerCase().contains('asthma')) {
      return '🫁';
    } else if (condition.toLowerCase().contains('cardiovasculaire') ||
        condition.toLowerCase().contains('cardiaque')) {
      return '❤️';
    } else {
      return '💊';
    }
  }
}