import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gradient_button.dart';
import '../application/goal_provider.dart';

class SetGoalScreen extends ConsumerStatefulWidget {
  const SetGoalScreen({super.key});

  @override
  ConsumerState<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends ConsumerState<SetGoalScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveGoal() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final name = _nameController.text.trim();
    if (amount <= 0 || name.isEmpty) return;

    setState(() => _isLoading = true);
    await ref.read(goalNotifierProvider.notifier).checkAndCreateGoal(name, amount, _selectedDate);
    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Goal'), backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g. New Car',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Target Amount (₹)',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Target Date', style: TextStyle(color: Colors.white70)),
              subtitle: Text(DateFormat.yMMMd().format(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.1))),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator(color: AppTheme.emerald)
                : SizedBox(
                    width: double.infinity,
                    child: GradientButton(text: 'Generate AI Path & Save', onPressed: _saveGoal),
                  ),
          ],
        ),
      ),
    );
  }
}
