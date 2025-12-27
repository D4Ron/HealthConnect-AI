import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../utils/app_colors.dart';
import '../auth/login_screen.dart';
import 'daily_questionnaire_screen.dart';
import 'medical_profile_screen.dart';
import 'health_history_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/consultation_pass_provider.dart';
import 'consultation_request_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final consultationProvider = Provider.of<ConsultationPassProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await healthProvider.loadMedicalProfile(authProvider.currentUser!.id);
      await healthProvider.loadHealthRecords(authProvider.currentUser!.id);

      // Check if consultation is needed
      await consultationProvider.checkConsultationNeed(authProvider.currentUser!.id);

      // Load active pass if exists
      await consultationProvider.loadActivePass(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final healthProvider = Provider.of<HealthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthConnect AI'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Welcome Card
            Text(
              'Bonjour ${user?.firstName ?? user?.email?.split('@')[0] ?? ''}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
// Consultation Suggestion Banner (if triggered)
            Consumer<ConsultationPassProvider>(
              builder: (context, consultationProvider, child) {
                if (consultationProvider.shouldShowConsultationSuggestion) {
                  return Card(
                    color: AppColors.warning.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.health_and_safety, color: AppColors.warning),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Consultation Recommandée',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: consultationProvider.dismissConsultationSuggestion,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Votre état de santé montre une baisse sur les 3 derniers jours.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ConsultationRequestScreen(
                                    autoTriggered: true,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.medical_services),
                            label: const Text('Demander une consultation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.warning,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),

// Manual Consultation Request Button
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ConsultationRequestScreen(
                        autoTriggered: false,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.medical_information,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demander une Consultation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Obtenez un Pass de Consultation',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: AppColors.textHint),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

// Medical Profile Status
            if (healthProvider.medicalProfile == null)
              Card(
                color: AppColors.warning.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Profil médical incomplet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          'Complétez votre profil médical pour commencer'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MedicalProfileScreen(),
                            ),
                          );
                        },
                        child: const Text('Compléter mon profil'),
                      ),
                    ],
                  ),
                ),
              )

            else
// Daily Questionnaire Card
              Card(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DailyQuestionnaireScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assignment,
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bilan Quotidien',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Complétez votre questionnaire du jour',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
              ),
            // Then add this card after the Daily Questionnaire Card in the build method:

            const SizedBox(height: 16),

// Health History Card
            Card(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HealthHistoryScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: AppColors.info,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historique de Santé',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Voir vos bilans précédents',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          color: AppColors.textHint),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

// Latest Record
            if (healthProvider.latestRecord != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dernier bilan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _getStatusColor(
                                healthProvider.latestRecord!.status),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusText(healthProvider.latestRecord!.status),
                            style: TextStyle(
                              color: _getStatusColor(
                                  healthProvider.latestRecord!.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
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

  String _getStatusText(String? status) {
    switch (status) {
      case 'stable':
        return 'Stable';
      case 'moderate':
        return 'Alerte modérée';
      case 'urgent':
        return 'Urgent';
      case 'critical':
        return 'Critique';
      default:
        return 'Inconnu';
    }
  }
}
