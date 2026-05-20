import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';

class AddSourceScreen extends StatefulWidget {
  const AddSourceScreen({super.key});

  @override
  State<AddSourceScreen> createState() => _AddSourceScreenState();
}

class _AddSourceScreenState extends State<AddSourceScreen> {
  final _nameController = TextEditingController();
  final _profileController = TextEditingController();
  final _startingBalanceController = TextEditingController();
  String _sourceType = 'Bank';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _profileController.dispose();
    _startingBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final isFirstRun = !appState.initialized || appState.sources.isEmpty;
    _profileController.text = _profileController.text.isEmpty
        ? appState.profile?.name ?? ''
        : _profileController.text;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            Text(
              isFirstRun ? 'Set up your finance tracker' : 'Add Source',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
                'Add cash, bank, or other money sources so every balance stays accurate.'),
            const SizedBox(height: 28),
            if (isFirstRun) ...[
              TextFormField(
                controller: _profileController,
                decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 14),
            ],
            DropdownButtonFormField<String>(
              value: _sourceType,
              decoration: const InputDecoration(
                  labelText: 'Source type',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined)),
              items: const [
                DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) =>
                  setState(() => _sourceType = value ?? 'Bank'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Source name',
                  prefixIcon: Icon(Icons.wallet_outlined)),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _startingBalanceController,
              decoration: const InputDecoration(
                  labelText: 'Starting balance',
                  prefixIcon: Icon(Icons.currency_rupee)),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : () => _save(isFirstRun),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(_saving ? 'Saving...' : 'Add source'),
              ),
            ),
            const SizedBox(height: 24),
            if (appState.sources.isNotEmpty) ...[
              Text('Sources',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...appState.sourceBalances().map((item) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined,
                          color: AppColors.purple),
                      title: Text(item.source.name),
                      subtitle: Text(item.source.type),
                      trailing: Text(appState.formatCurrency(item.balance)),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save(bool isFirstRun) async {
    final name = _nameController.text.trim();
    final profileName = _profileController.text.trim();
    final amount = double.tryParse(_startingBalanceController.text) ?? 0;
    if (name.isEmpty || (isFirstRun && profileName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill the required fields')));
      return;
    }
    final appState = context.read<AppStateModel>();
    setState(() => _saving = true);
    if (isFirstRun) {
      await appState.setProfile(profileName);
    }
    await appState.addSource(name, _sourceType, amount);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushReplacementNamed('/');
  }
}
