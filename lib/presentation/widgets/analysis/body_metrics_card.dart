import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

import '../../../data/database/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/appflowy_theme.dart';
import '../../providers/providers.dart';

/// Body metrics card widget for displaying and editing body measurements
class BodyMetricsCard extends ConsumerStatefulWidget {
  const BodyMetricsCard({super.key});

  @override
  ConsumerState<BodyMetricsCard> createState() => _BodyMetricsCardState();
}

class _BodyMetricsCardState extends ConsumerState<BodyMetricsCard> {
  bool _isEditing = false;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String? _selectedGender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _initControllers(BodyMetric? metrics) {
    if (metrics != null) {
      if (_weightController.text.isEmpty && metrics.weight != null) {
        _weightController.text = metrics.weight!.toStringAsFixed(1);
      }
      if (_heightController.text.isEmpty && metrics.height != null) {
        _heightController.text = metrics.height!.toStringAsFixed(0);
      }
      if (_selectedGender == null && metrics.gender != null) {
        _selectedGender = metrics.gender;
      }
    }
  }

  Future<void> _saveBodyMetrics() async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() => _isSaving = true);
    
    try {
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);
      
      final db = ref.read(databaseProvider);
      await db.insertBodyMetrics(BodyMetricsCompanion(
        id: Value(const Uuid().v4()),
        weight: Value(weight),
        height: Value(height),
        gender: Value(_selectedGender),
        recordedAt: Value(DateTime.now().toUtc()),
      ));
      
      // Refresh the provider
      ref.invalidate(bodyMetricsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bodyMetricsSaved),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyMetricsAsync = ref.watch(bodyMetricsProvider);
    final bmi = ref.watch(bmiProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.people),
                const SizedBox(width: 8),
                Text(
                  l10n.bodyMetrics,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      setState(() => _isEditing = true);
                      _initControllers(null);
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _weightController.clear();
                        _heightController.clear();
                        _selectedGender = null;
                      });
                    },
                  ),
              ],
            ),
            const Divider(),
            
            bodyMetricsAsync.when(
              data: (metrics) {
                _initControllers(metrics);
                
                if (!_isEditing) {
                  // Display mode
                  return _buildDisplayMode(context, l10n, metrics, bmi, isDark);
                } else {
                  // Edit mode
                  return _buildEditMode(context, l10n, isDark);
                }
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, s) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('${l10n.error}: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayMode(
    BuildContext context,
    AppLocalizations l10n,
    BodyMetric? metrics,
    double? bmi,
    bool isDark,
  ) {
    if (metrics == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 48,
                color: isDark ? Colors.white54 : Colors.black38,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noData,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black38,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.add),
                label: Text(l10n.edit),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Weight and Height
        Row(
          children: [
            Expanded(
              child: _MetricItem(
                icon: Icons.fitness_center,
                label: l10n.weight,
                value: metrics.weight != null 
                    ? '${metrics.weight!.toStringAsFixed(1)} ${l10n.kg}'
                    : '-',
              ),
            ),
            Expanded(
              child: _MetricItem(
                icon: Icons.height,
                label: l10n.height,
                value: metrics.height != null 
                    ? '${metrics.height!.toStringAsFixed(0)} ${l10n.cm}'
                    : '-',
              ),
            ),
            Expanded(
              child: _MetricItem(
                icon: Icons.person,
                label: l10n.gender,
                value: metrics.gender == 'male' 
                    ? l10n.male 
                    : (metrics.gender == 'female' ? l10n.female : '-'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // BMI and Relative Strength
        Row(
          children: [
            Expanded(
              child: _MetricItem(
                icon: Icons.monitor_weight,
                label: l10n.bmi,
                value: bmi != null ? bmi.toStringAsFixed(1) : '-',
                highlight: bmi != null && bmi >= 18.5 && bmi < 24.9,
              ),
            ),
            Expanded(
              child: _MetricItem(
                icon: Icons.trending_up,
                label: l10n.relativeStrength,
                value: '-',
                subValue: l10n.perKg,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildEditMode(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weight input
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.weight,
            hintText: l10n.enterWeight,
            suffixText: l10n.kg,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        
        // Height input
        TextField(
          controller: _heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.height,
            hintText: l10n.enterHeight,
            suffixText: l10n.cm,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        
        // Gender selection
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            labelText: l10n.gender,
            hintText: l10n.selectGender,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(
              value: 'male',
              child: Text(l10n.male),
            ),
            DropdownMenuItem(
              value: 'female',
              child: Text(l10n.female),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedGender = value);
          },
        ),
        const SizedBox(height: 16),
        
        // Save button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSaving ? null : _saveBodyMetrics,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final bool highlight;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: highlight
          ? BoxDecoration(
              color: MusclockBrandColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: MusclockBrandColors.primary.withOpacity(0.3),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: MusclockBrandColors.primary),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: highlight ? MusclockBrandColors.primary : null,
                ),
              ),
              if (subValue != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 2),
                  child: Text(
                    subValue!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
