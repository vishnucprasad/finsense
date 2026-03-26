import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/gradient_button.dart';
import '../../../core/models/transaction_model.dart';
import '../application/transaction_provider.dart';
import '../../accounts/application/account_provider.dart';
import '../../categories/application/category_provider.dart';

class TransactionEntryScreen extends ConsumerStatefulWidget {
  final TransactionModel? existingTransaction;

  const TransactionEntryScreen({super.key, this.existingTransaction});

  @override
  ConsumerState<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends ConsumerState<TransactionEntryScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'Expense';
  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      _amountController.text = widget.existingTransaction!.amount.toString();
      _noteController.text = widget.existingTransaction!.note;
      _selectedDate = widget.existingTransaction!.date;
      _transactionType = widget.existingTransaction!.type;
      _selectedAccountId = widget.existingTransaction!.accountId.isNotEmpty ? widget.existingTransaction!.accountId : null;
      _selectedCategoryId = widget.existingTransaction!.categoryId.isNotEmpty ? widget.existingTransaction!.categoryId : null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    if (_selectedAccountId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an Account and Category')));
      return;
    }

    final transaction = TransactionModel(
      id: widget.existingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      note: _noteController.text.trim(),
      accountId: _selectedAccountId!,
      type: _transactionType,
    );

    if (widget.existingTransaction == null) {
      ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
    } else {
      ref.read(transactionNotifierProvider.notifier).editTransaction(transaction, widget.existingTransaction!);
    }

    context.pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTransaction == null ? 'New Transaction' : 'Edit Transaction'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_transactionType != 'Income') {
                        setState(() {
                          _transactionType = 'Income';
                          _selectedCategoryId = null;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _transactionType == 'Income' ? AppTheme.emerald.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        border: Border.all(color: _transactionType == 'Income' ? AppTheme.emerald : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('Income', style: TextStyle(color: _transactionType == 'Income' ? AppTheme.emerald : Colors.white))),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_transactionType != 'Expense') {
                        setState(() {
                          _transactionType = 'Expense';
                          _selectedCategoryId = null;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _transactionType == 'Expense' ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        border: Border.all(color: _transactionType == 'Expense' ? Colors.redAccent : Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('Expense', style: TextStyle(color: _transactionType == 'Expense' ? Colors.redAccent : Colors.white))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.currency_rupee, color: _transactionType == 'Income' ? AppTheme.emerald : Colors.redAccent),
              ),
            ),
            const SizedBox(height: 20),
            accountsAsync.when(
              data: (accounts) {
                if (accounts.isEmpty) return const Text('No accounts found. Create one first.', style: TextStyle(color: Colors.redAccent));
                
                if (_selectedAccountId != null && !accounts.any((a) => a.id == _selectedAccountId)) {
                  _selectedAccountId = null;
                }

                return DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: InputDecoration(
                    labelText: 'Source Account',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  dropdownColor: AppTheme.deepNavy,
                  items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedAccountId = val);
                  },
                );
              },
              loading: () => const CircularProgressIndicator(color: AppTheme.emerald),
              error: (e, _) => const Text('Error loading accounts'),
            ),
            const SizedBox(height: 20),
            categoriesAsync.when(
              data: (categories) {
                final filtered = categories.where((c) => c.type == _transactionType).toList();
                if (filtered.isEmpty) return const Text('No categories found.', style: TextStyle(color: Colors.redAccent));
                
                if (_selectedCategoryId != null && !filtered.any((c) => c.id == _selectedCategoryId)) {
                  _selectedCategoryId = null;
                }

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  dropdownColor: AppTheme.deepNavy,
                  items: filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategoryId = val);
                  },
                );
              },
              loading: () => const CircularProgressIndicator(color: AppTheme.emerald),
              error: (e, _) => const Text('Error loading categories'),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Date', style: TextStyle(color: Colors.white70)),
              subtitle: Text(DateFormat.yMMMd().format(_selectedDate), style: const TextStyle(color: Colors.white, fontSize: 16)),
              trailing: const Icon(Icons.calendar_today, color: AppTheme.cyan),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.1))),
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Save Transaction',
                onPressed: _saveTransaction,
              ),
            )
          ],
        ),
      ),
    );
  }
}
