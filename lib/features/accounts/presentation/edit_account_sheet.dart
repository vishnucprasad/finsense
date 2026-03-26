import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gradient_button.dart';
import '../../../core/models/account_model.dart';
import '../application/account_provider.dart';

class EditAccountSheet extends ConsumerStatefulWidget {
  final AccountModel account;
  const EditAccountSheet({super.key, required this.account});

  @override
  ConsumerState<EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends ConsumerState<EditAccountSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late String _selectedType;
  late String _selectedColor;

  final List<String> _types = ['Bank', 'Card', 'Cash'];
  final List<String> _colors = ['ff3b82f6', 'ff10b981', 'ff8b5cf6', 'fff59e0b', 'fff43f5e'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _balanceController = TextEditingController(text: widget.account.balance.toStringAsFixed(2));
    _selectedType = widget.account.type;
    _selectedColor = widget.account.colorHex;

    if (!_types.contains(_selectedType)) _selectedType = 'Bank';
    if (!_colors.contains(_selectedColor)) _selectedColor = 'ff3b82f6';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    final name = _nameController.text.trim();
    final balance = double.tryParse(_balanceController.text) ?? 0.0;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account name cannot be empty'), backgroundColor: Colors.redAccent));
      return;
    }

    final updatedAcc = AccountModel(
      id: widget.account.id,
      name: name,
      type: _selectedType,
      balance: balance,
      colorHex: _selectedColor,
    );
    
    ref.read(accountNotifierProvider.notifier).updateAccount(updatedAcc);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edit Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Account Name (e.g., Chase Checking)',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _balanceController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Current Balance (₹)',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Account Type',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            dropdownColor: AppTheme.deepNavy,
            items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          const SizedBox(height: 16),
          const Text('Card Color', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _colors.map((c) {
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(int.parse(c, radix: 16)),
                  child: _selectedColor == c ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: GradientButton(text: 'Update Account', onPressed: _saveAccount),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
