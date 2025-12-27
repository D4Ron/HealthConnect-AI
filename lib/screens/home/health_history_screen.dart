import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/health_provider.dart';
import '../../utils/app_colors.dart';

class HealthHistoryScreen extends StatelessWidget {
  const HealthHistoryScreen({super.key});

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
        return 'Modéré';
      case 'urgent':
        return 'Urgent';
      case 'critical':
        return 'Critique';
      default:
        return 'Inconnu';
    }
  }

  IconData _getStatusIcon(String? status) {
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

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);
    final records = healthProvider.healthRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de Santé'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: records.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun historique',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez votre suivi quotidien',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final date = record.timestamp;
          final formattedDate = DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(date);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                _showRecordDetails(context, record);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getStatusColor(record.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(record.status),
                        color: _getStatusColor(record.status),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(record.status),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(record.status),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (record.riskScore != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${record.riskScore}/100',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRecordDetails(BuildContext context, dynamic record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final date = record.timestamp;
        final formattedDate = DateFormat('d MMMM yyyy à HH:mm', 'fr_FR').format(date);

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Détails du Bilan',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(record.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(record.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(record.status),
                          color: _getStatusColor(record.status),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getStatusText(record.status),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(record.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vital Signs
                  if (record.vitalSigns != null && record.vitalSigns!.isNotEmpty) ...[
                    const Text(
                      'Signes Vitaux',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (record.vitalSigns!['systolic_bp'] != null)
                              _buildVitalRow(
                                '🩺 Tension Artérielle',
                                '${record.vitalSigns!['systolic_bp']}/${record.vitalSigns!['diastolic_bp']} mmHg',
                              ),
                            if (record.vitalSigns!['heart_rate'] != null)
                              _buildVitalRow(
                                '❤️ Fréquence Cardiaque',
                                '${record.vitalSigns!['heart_rate']} bpm',
                              ),
                            if (record.vitalSigns!['glucose'] != null)
                              _buildVitalRow(
                                '🩸 Glycémie',
                                '${record.vitalSigns!['glucose']} mg/dL',
                              ),
                            if (record.vitalSigns!['weight'] != null)
                              _buildVitalRow(
                                '⚖️ Poids',
                                '${record.vitalSigns!['weight']} kg',
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Risk Score
                  if (record.riskScore != null) ...[
                    const Text(
                      'Score de Risque',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: record.riskScore! / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatusColor(record.status),
                      ),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${record.riskScore}/100',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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