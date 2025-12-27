class AIAnalysisService {
  // Analyze vital signs based on medical guidelines
  static Map<String, dynamic> analyzeVitalSigns({
    int? systolicBP,
    int? diastolicBP,
    int? heartRate,
    int? glucose,
    double? weight,
    Map<String, dynamic>? questionnaireResponses,
  }) {
    List<String> anomalies = [];
    List<String> warnings = [];
    List<String> recommendations = [];
    int riskScore = 0;
    String status = 'stable';

    // Blood Pressure Analysis
    if (systolicBP != null && diastolicBP != null) {
      if (systolicBP >= 180 || diastolicBP >= 120) {
        anomalies.add('Crise hypertensive (TA: $systolicBP/$diastolicBP)');
        riskScore += 40;
        recommendations.add('🚨 Consultez immédiatement un médecin');
      } else if (systolicBP >= 140 || diastolicBP >= 90) {
        warnings.add('Tension artérielle élevée ($systolicBP/$diastolicBP)');
        riskScore += 25;
        recommendations.add('📞 Consultez votre médecin dans les 48h');
      } else if (systolicBP < 90 || diastolicBP < 60) {
        warnings.add('Tension artérielle basse ($systolicBP/$diastolicBP)');
        riskScore += 15;
        recommendations.add('Surveillez vos symptômes (vertiges, fatigue)');
      }
    }

    // Glucose Analysis (for diabetics)
    if (glucose != null) {
      if (glucose >= 300) {
        anomalies.add('Glycémie très élevée ($glucose mg/dL)');
        riskScore += 35;
        recommendations.add('🚨 Risque d\'hyperglycémie - Consultez rapidement');
      } else if (glucose >= 250) {
        warnings.add('Glycémie élevée ($glucose mg/dL)');
        riskScore += 25;
        recommendations.add('Contactez votre médecin aujourd\'hui');
      } else if (glucose < 70) {
        anomalies.add('Hypoglycémie ($glucose mg/dL)');
        riskScore += 30;
        recommendations.add('🚨 Prenez du sucre rapide immédiatement');
      } else if (glucose > 180) {
        warnings.add('Glycémie au-dessus de l\'objectif ($glucose mg/dL)');
        riskScore += 15;
        recommendations.add('Surveillez votre alimentation');
      }
    }

    // Heart Rate Analysis
    if (heartRate != null) {
      if (heartRate > 120) {
        warnings.add('Fréquence cardiaque élevée ($heartRate bpm)');
        riskScore += 20;
        recommendations.add('Repos et surveillance recommandés');
      } else if (heartRate < 50) {
        warnings.add('Fréquence cardiaque basse ($heartRate bpm)');
        riskScore += 20;
        recommendations.add('Consultez si symptômes (fatigue, vertiges)');
      }
    }

    // Determine status based on risk score
    if (riskScore >= 60) {
      status = 'critical';
    } else if (riskScore >= 40) {
      status = 'urgent';
    } else if (riskScore >= 20) {
      status = 'moderate';
    } else {
      status = 'stable';
    }

    // Add positive feedback for stable status
    if (status == 'stable') {
      recommendations.add('✅ Tous vos signes vitaux sont dans les normes');
      recommendations.add('💪 Continuez vos bonnes habitudes de santé');
    }

    return {
      'status': status,
      'risk_score': riskScore,
      'anomalies': anomalies,
      'warnings': warnings,
      'recommendations': recommendations,
      'analysis_timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Combine questionnaire and vital signs analysis
  static Map<String, dynamic> comprehensiveAnalysis({
    Map<String, dynamic>? vitalSigns,
    Map<String, dynamic>? questionnaireResponses,
  }) {
    // Extract vital signs
    int? systolicBP = vitalSigns?['systolic_bp'];
    int? diastolicBP = vitalSigns?['diastolic_bp'];
    int? heartRate = vitalSigns?['heart_rate'];
    int? glucose = vitalSigns?['glucose'];
    double? weight = vitalSigns?['weight']?.toDouble();

    // Perform analysis
    final analysis = analyzeVitalSigns(
      systolicBP: systolicBP,
      diastolicBP: diastolicBP,
      heartRate: heartRate,
      glucose: glucose,
      weight: weight,
      questionnaireResponses: questionnaireResponses,
    );

    return analysis;
  }

  // Get status color code
  static String getStatusColorCode(String status) {
    switch (status) {
      case 'stable':
        return '#4CAF50';
      case 'moderate':
        return '#FF9800';
      case 'urgent':
        return '#FF5722';
      case 'critical':
        return '#F44336';
      default:
        return '#2196F3';
    }
  }

  // Get status message
  static String getStatusMessage(String status) {
    switch (status) {
      case 'stable':
        return 'Vos signes vitaux sont normaux';
      case 'moderate':
        return 'Certains signes nécessitent surveillance';
      case 'urgent':
        return 'Consultation médicale recommandée sous 48h';
      case 'critical':
        return 'Consultation médicale urgente requise';
      default:
        return 'Analyse en cours';
    }
  }
}