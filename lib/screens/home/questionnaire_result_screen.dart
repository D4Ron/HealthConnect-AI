import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/health_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import 'home_screen.dart';
import 'vital_signs_screen.dart';

class QuestionnaireResultScreen extends StatelessWidget {
  final String status;

  const QuestionnaireResultScreen({
    super.key,
    required this.status,
  });

  Color _getStatusColor() {
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

  String _getStatusMessage() {
    switch (status) {
      case 'stable':
        return 'Excellente nouvelle ! Tous vos indicateurs sont bons.';
      case 'moderate':
        return 'Attention : Certains indicateurs nécessitent surveillance.';
      case 'urgent':
        return 'Alerte : Consultation médicale recommandée dans les 48h.';
      case 'critical':
        return 'Alerte Critique : Consultation médicale urgente requise.';
      default:
        return 'Analyse terminée.';
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case 'stable':
        return 'Statut : Stable';
      case 'moderate':
        return 'Statut : Alerte Modérée';
      case 'urgent':
        return 'Statut : Urgent';
      case 'critical':
        return 'Statut : Critique';
      default:
        return 'Statut : Analysé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final consecutiveDays = healthProvider.consecutiveStableDays;

    return Scaffold(
        appBar: AppBar(
          title: const Text('Résultat de l\'analyse'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
              // Status Icon
              Container(
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
            const SizedBox(height: 24),
            // Status Title
            Text(
              _getStatusTitle(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(),
              ),
            ),
            const SizedBox(height: 12),
            // Status Message
            Text(
              _getStatusMessage(),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Consecutive Stable Days
            if (status == 'stable' && consecutiveDays > 0)
        Container(
        padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: AppColors.success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.success),
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    const Icon(Icons.local_fire_department,
    color: AppColors.success),
    const SizedBox(width: 8),
    Text(
    '$consecutiveDays jours stables consécutifs !',
    style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 32),
    // Action Buttons
    CustomButton(
    text: 'Ajouter mes signes vitaux',
    onPressed: () {
    Navigator.of(context).pushReplacement(
    MaterialPageRoute(
    builder: (_) => const VitalSignsScreen(),
    ),
    );
    },
    ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                    );
                  },
                  child: const Text('Plus tard'),
                ),
              ],
            ),
        ),
    );
  }
}
