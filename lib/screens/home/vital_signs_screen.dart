import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../services/ai_analysis_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'vital_signs_result_screen.dart';

class VitalSignsScreen extends StatefulWidget {
  const VitalSignsScreen({super.key});

  @override
  State<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends State<VitalSignsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _weightController = TextEditingController();

  bool _showGlucose = false;

  @override
  void initState() {
    super.initState();
    _checkConditions();
  }

  void _checkConditions() {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final conditions = healthProvider.medicalProfile?.conditions ?? [];

    // Show glucose field if user has diabetes
    _showGlucose = conditions.any((c) =>
    c.toLowerCase().contains('diabète') ||
        c.toLowerCase().contains('diabetes')
    );
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _glucoseController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitVitalSigns() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    // Prepare vital signs data with proper types
    final vitalSigns = <String, dynamic>{};

    int? systolicBP;
    int? diastolicBP;
    int? heartRate;
    int? glucose;
    double? weight;

    if (_systolicController.text.isNotEmpty && _diastolicController.text.isNotEmpty) {
      systolicBP = int.parse(_systolicController.text);
      diastolicBP = int.parse(_diastolicController.text);
      vitalSigns['systolic_bp'] = systolicBP;
      vitalSigns['diastolic_bp'] = diastolicBP;
    }

    if (_heartRateController.text.isNotEmpty) {
      heartRate = int.parse(_heartRateController.text);
      vitalSigns['heart_rate'] = heartRate;
    }

    if (_glucoseController.text.isNotEmpty) {
      glucose = int.parse(_glucoseController.text);
      vitalSigns['glucose'] = glucose;
    }

    if (_weightController.text.isNotEmpty) {
      weight = double.parse(_weightController.text);
      vitalSigns['weight'] = weight;
    }

    // Perform AI analysis with properly typed variables
    final analysis = AIAnalysisService.analyzeVitalSigns(
      systolicBP: systolicBP,
      diastolicBP: diastolicBP,
      heartRate: heartRate,
      glucose: glucose,
      weight: weight,
    );

    // Save to database
    final success = await healthProvider.submitHealthCheckIn(
      userId: authProvider.currentUser!.id,
      vitalSigns: vitalSigns,
      riskScore: analysis['risk_score'],
      status: analysis['status'],
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VitalSignsResultScreen(
            analysis: analysis,
            vitalSigns: vitalSigns,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signes Vitaux'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enregistrez vos mesures',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Saisissez les valeurs que vous avez mesurées',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Blood Pressure
              const Text(
                '🩺 Tension Artérielle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Systolique',
                      hint: '120',
                      controller: _systolicController,
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateBloodPressure(
                        value,
                        isSystolic: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Diastolique',
                      hint: '80',
                      controller: _diastolicController,
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateBloodPressure(
                        value,
                        isSystolic: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Heart Rate
              CustomTextField(
                label: '❤️ Fréquence Cardiaque (bpm)',
                hint: '75',
                controller: _heartRateController,
                keyboardType: TextInputType.number,
                validator: Validators.validateHeartRate,
              ),
              const SizedBox(height: 24),

              // Glucose (conditional)
              if (_showGlucose) ...[
                CustomTextField(
                  label: '🩸 Glycémie (mg/dL)',
                  hint: '100',
                  controller: _glucoseController,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateGlucose,
                ),
                const SizedBox(height: 24),
              ],

              // Weight
              CustomTextField(
                label: '⚖️ Poids (kg) - Optionnel',
                hint: '70',
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 20 || weight > 300) {
                    return 'Doit être entre 20 et 300 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Au moins 2 mesures sont requises pour l\'analyse',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                text: 'Analyser mes signes vitaux',
                onPressed: _submitVitalSigns,
                isLoading: healthProvider.isLoading,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}