import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../providers/consultation_pass_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'consultation_pass_screen.dart';

class ConsultationRequestScreen extends StatefulWidget {
  final bool autoTriggered;

  const ConsultationRequestScreen({
    super.key,
    required this.autoTriggered,
  });

  @override
  State<ConsultationRequestScreen> createState() =>
      _ConsultationRequestScreenState();
}

class _ConsultationRequestScreenState extends State<ConsultationRequestScreen> {
  final _reasonController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    setState(() {
      _isProcessing = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final consultationProvider =
    Provider.of<ConsultationPassProvider>(context, listen: false);

    final user = authProvider.currentUser;
    final medicalProfile = healthProvider.medicalProfile;
    final healthHistory = healthProvider.healthRecords;

    if (user == null || medicalProfile == null) {
      setState(() {
        _isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil médical incomplet'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await consultationProvider.requestConsultation(
      user: user,
      medicalProfile: medicalProfile,
      healthHistory: healthHistory,
      reason: _reasonController.text.trim().isEmpty
          ? (widget.autoTriggered ? 'Baisse de santé détectée' : 'Demande manuelle')
          : _reasonController.text.trim(),
    );

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ConsultationPassScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(consultationProvider.errorMessage ??
              'Erreur lors de la demande'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de Consultation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.autoTriggered) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.warning),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Votre santé montre une baisse sur 3 jours consécutifs',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Demande de Consultation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Un Pass de Consultation sera généré avec votre historique médical des 30 derniers jours',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Raison de la consultation (optionnel)',
              hint: 'Ex: Douleurs abdominales, fatigue persistante...',
              controller: _reasonController,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            const Text(
              'Informations envoyées :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.person,
              title: 'Profil Patient',
              description: 'Nom, conditions, médicaments, allergies',
            ),
            const SizedBox(height: 8),
            _buildInfoCard(
              icon: Icons.history,
              title: 'Historique 30 jours',
              description: 'Signes vitaux, questionnaires, scores de risque',
            ),
            const SizedBox(height: 8),
            _buildInfoCard(
              icon: Icons.analytics,
              title: 'Analyse IA',
              description: 'Tendances et résumé clinique',
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: _isProcessing
                  ? 'Génération en cours...'
                  : 'Générer mon Pass de Consultation',
              onPressed: _isProcessing ? () {} : _submitRequest,
              isLoading: _isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
          children: [
          Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }
}