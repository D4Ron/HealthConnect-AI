import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/medical_conditions.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'home_screen.dart';

class MedicalProfileScreen extends StatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  State<MedicalProfileScreen> createState() => _MedicalProfileScreenState();
}

class _MedicalProfileScreenState extends State<MedicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _medicationController = TextEditingController();
  final _allergyController = TextEditingController();

  final List<String> _selectedConditions = [];
  final List<String> _medications = [];
  final List<String> _allergies = [];
  String _selectedBloodType = 'Inconnu';
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  void _loadExistingProfile() {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final profile = healthProvider.medicalProfile;

    if (profile != null) {
      setState(() {
        _selectedConditions.addAll(profile.conditions);
        _medications.addAll(profile.medications);
        _allergies.addAll(profile.allergies);
        _selectedBloodType = profile.bloodType ?? 'Inconnu';
        _dateOfBirth = profile.dateOfBirth;
        _emergencyContactController.text = profile.emergencyContact ?? '';
        _emergencyPhoneController.text = profile.emergencyPhone ?? '';
      });
    }
  }

  @override
  void dispose() {
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _medicationController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  void _addMedication() {
    if (_medicationController.text.trim().isNotEmpty) {
      setState(() {
        _medications.add(_medicationController.text.trim());
        _medicationController.clear();
      });
    }
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _addAllergy() {
    if (_allergyController.text.trim().isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text.trim());
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedConditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une condition'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);

    final success = await healthProvider.saveMedicalProfile(
      userId: authProvider.currentUser!.id,
      conditions: _selectedConditions,
      medications: _medications,
      allergies: _allergies,
      dateOfBirth: _dateOfBirth,
      bloodType: _selectedBloodType,
      emergencyContact: _emergencyContactController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil médical enregistré avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(healthProvider.errorMessage ?? 'Erreur lors de l\'enregistrement'),
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
        title: const Text('Profil Médical'),
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
                'Configuration du profil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ces informations permettent une analyse personnalisée',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Conditions
              const Text(
                'Conditions Médicales *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MedicalConditions.commonConditions.map((condition) {
                  final isSelected = _selectedConditions.contains(condition);
                  return FilterChip(
                    label: Text(condition),
                    selected: isSelected,
                    onSelected: (_) => _toggleCondition(condition),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Date of Birth
              const Text(
                'Date de Naissance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDateOfBirth,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          fontSize: 16,
                          color: _dateOfBirth != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Blood Type
              const Text(
                'Groupe Sanguin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: MedicalConditions.bloodTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value!;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Medications
              const Text(
                'Médicaments Actuels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _medicationController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Metformine 1000mg',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    iconSize: 36,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_medications.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _medications.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeMedication(entry.key),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),

              // Allergies
              const Text(
                'Allergies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergyController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Pénicilline',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addAllergy,
                    icon: const Icon(Icons.add_circle, color: AppColors.primary),
                    iconSize: 36,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_allergies.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allergies.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeAllergy(entry.key),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),

              // Emergency Contact
              CustomTextField(
                label: 'Contact d\'Urgence',
                hint: 'Nom du contact',
                controller: _emergencyContactController,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Téléphone d\'Urgence',
                hint: '+228 XX XX XX XX',
                controller: _emergencyPhoneController,
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: 'Enregistrer le profil',
                onPressed: _saveProfile,
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