import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import 'home_screen.dart';

class VitalSignsResultScreen extends StatelessWidget {
  final Map<String, dynamic> analysis;
  final Map<String, dynamic> vitalSigns;

  const VitalSignsResultScreen({
    super.key,
    required this.analysis,
    required this.vitalSigns,
  });

  Color _getStatusColor() {
    final status = analysis['status'];
    switch (status) {
      case 'stable':
        return AppColors.stable;
      case 'moderate':
        return AppColors.moderate;
      case 'urgent':
        return AppColors.urgent;
      case 'critical':
        return AppColors.critical;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon() {
    final status = analysis['status'];
    switch (status) {
      case 'stable':
        return Icons.check_circle;
      case 'moderate':
        return Icons.warning_amber;
      case 'urgent':
        return Icons.error;
      case 'critical':
        return Icons.emergency;
      default:
        return Icons.info;
    }
  }

  String _getStatusTitle() {
    final status = analysis['status'];
    switch (status) {
      case 'stable':
        return 'Signes Vitaux Normaux';
      case 'moderate':
        return 'Surveillance Recommandée';
      case 'urgent':
        return 'Attention Requise';
      case 'critical':
        return 'Alerte Critique';
      default:
        return 'Analyse Terminée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = analysis['status'];
    final riskScore = analysis['risk_score'];
    final anomalies = List<String>.from(analysis['anomalies'] ?? []);
    final warnings = List<String>.from(analysis['warnings'] ?? []);
    final recommendations = List<String>.from(analysis['recommendations'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse Complète'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(),
                  size: 50,
                  color: _getStatusColor(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Status Title
            Center(
              child: Text(
                _getStatusTitle(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // Risk Score
            Center(
              child: Text(
                'Score de risque : $riskScore/100',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Vital Signs Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vos mesures',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (vitalSigns['systolic_bp'] != null)
                      _buildMeasurementRow(
                        '🩺 Tension',
                        '${vitalSigns['systolic_bp']}/${vitalSigns['diastolic_bp']} mmHg',
                      ),
                    if (vitalSigns['heart_rate'] != null)
                      _buildMeasurementRow(
                        '❤️ Fréquence cardiaque',
                        '${vitalSigns['heart_rate']} bpm',
                      ),
                    if (vitalSigns['glucose'] != null)
                      _buildMeasurementRow(
                        '🩸 Glycémie',
                        '${vitalSigns['glucose']} mg/dL',
                      ),
                    if (vitalSigns['weight'] != null)
                      _buildMeasurementRow(
                        '⚖️ Poids',
                        '${vitalSigns['weight']} kg',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Anomalies
            if (anomalies.isNotEmpty) ...[
              Card(
                color: AppColors.critical.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: AppColors.critical),
                          const SizedBox(width: 8),
                          const Text(
                            'Anomalies Détectées',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...anomalies.map((anomaly) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $anomaly'),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Warnings
            if (warnings.isNotEmpty) ...[
              Card(
                color: AppColors.warning.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.warning),
                          const SizedBox(width: 8),
                          const Text(
                            'Points d\'Attention',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...warnings.map((warning) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $warning'),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Recommendations
            if (recommendations.isNotEmpty) ...[
              Card(
                color: AppColors.info.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.info),
                          const SizedBox(width: 8),
                          const Text(
                            'Recommandations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(rec),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),

            // Action Button
            CustomButton(
              text: 'Retour à l\'accueil',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}