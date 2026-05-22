import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

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
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateModel>();
    final isFirstRun = !appState.initialized || appState.sources.isEmpty;
    _profileController.text = _profileController.text.isEmpty
        ? appState.profile?.name ?? ''
        : _profileController.text;

    if (isFirstRun) {
      return Scaffold(
        body: SafeArea(
          child: Responsive.constrained(
            context,
            ListView(
              padding: EdgeInsets.all(20.r(context)),
              children: [
                SizedBox(height: 24.r(context)),
                Text(
                  'Set up your finance tracker',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900, fontSize: 24.r(context)),
                ),
                SizedBox(height: 8.r(context)),
                Text(
                  'Add cash, bank, or other money sources so every balance stays accurate.',
                  style: TextStyle(fontSize: 14.r(context)),
                ),
                SizedBox(height: 28.r(context)),
                TextFormField(
                  controller: _profileController,
                  style: TextStyle(fontSize: 14.r(context)),
                  decoration: InputDecoration(
                      labelText: 'Your name',
                      labelStyle: TextStyle(fontSize: 13.r(context)),
                      prefixIcon: Icon(Icons.person_outline, size: 20.r(context))),
                ),
                SizedBox(height: 14.r(context)),
                DropdownButtonFormField<String>(
                  value: _sourceType,
                  dropdownColor: AppColors.darkCard,
                  style: TextStyle(fontSize: 14.r(context), color: AppColors.textPrimary),
                  decoration: InputDecoration(
                      labelText: 'Source type',
                      labelStyle: TextStyle(fontSize: 13.r(context)),
                      prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20.r(context))),
                  items: const [
                    DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) =>
                      setState(() => _sourceType = value ?? 'Bank'),
                ),
                SizedBox(height: 14.r(context)),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 14.r(context)),
                  decoration: InputDecoration(
                      labelText: 'Source name',
                      labelStyle: TextStyle(fontSize: 13.r(context)),
                      prefixIcon: Icon(Icons.wallet_outlined, size: 20.r(context))),
                ),
                SizedBox(height: 14.r(context)),
                TextFormField(
                  controller: _startingBalanceController,
                  style: TextStyle(fontSize: 14.r(context)),
                  decoration: InputDecoration(
                      labelText: 'Starting balance',
                      labelStyle: TextStyle(fontSize: 13.r(context)),
                      prefixIcon: Icon(Icons.currency_rupee, size: 20.r(context))),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 24.r(context)),
                FilledButton(
                  onPressed: _saving ? null : () => _save(isFirstRun),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.r(context)),
                    child: Text(_saving ? 'Saving...' : 'Add source', style: TextStyle(fontSize: 14.r(context))),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isTablet = Responsive.isTablet(context);

    final content = Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        maxWidth: isTablet ? 500.r(context) : double.infinity,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: isTablet
            ? BorderRadius.circular(28.r(context))
            : BorderRadius.vertical(top: Radius.circular(28.r(context))),
        border: isTablet
            ? Border.all(color: AppColors.darkBorder)
            : const Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Form(
        child: ListView(
          shrinkWrap: isTablet,
          padding: EdgeInsets.fromLTRB(20.r(context), 10.r(context), 20.r(context), 28.r(context)),
          children: [
            Center(
              child: Container(
                width: 44.r(context),
                height: 5.r(context),
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(4.r(context)),
                ),
              ),
            ),
            SizedBox(height: 16.r(context)),
            Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close,
                        color: AppColors.textPrimary, size: 30.r(context))),
                Expanded(
                  child: Text.rich(
                    const TextSpan(
                      text: 'Add ',
                      children: [
                        TextSpan(
                            text: 'Source',
                            style: TextStyle(color: AppColors.blue)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22.r(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 48.r(context)),
              ],
            ),
            SizedBox(height: 20.r(context)),
            DropdownButtonFormField<String>(
              value: _sourceType,
              dropdownColor: AppColors.darkCard,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.r(context),
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Source type',
                labelStyle: TextStyle(fontSize: 12.r(context)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20.r(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) =>
                  setState(() => _sourceType = value ?? 'Bank'),
            ),
            SizedBox(height: 14.r(context)),
            TextFormField(
              controller: _nameController,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.r(context),
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Source name',
                labelStyle: TextStyle(fontSize: 12.r(context)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
                prefixIcon: Icon(Icons.wallet_outlined, size: 20.r(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
            SizedBox(height: 14.r(context)),
            TextFormField(
              controller: _startingBalanceController,
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.r(context),
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                labelText: 'Starting balance',
                labelStyle: TextStyle(fontSize: 12.r(context)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.r(context), vertical: 12.r(context)),
                prefixIcon: Icon(Icons.currency_rupee, size: 20.r(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 24.r(context)),
            FilledButton(
              onPressed: _saving ? null : () => _save(isFirstRun),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.r(context)),
                child: Text(_saving ? 'Saving...' : 'Add source', style: TextStyle(fontSize: 13.r(context))),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.transparent,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: isTablet ? Alignment.center : Alignment.bottomCenter,
              child: Padding(
                padding: isTablet ? EdgeInsets.symmetric(horizontal: 24.r(context)) : EdgeInsets.zero,
                child: content,
              ),
            ),
          ),
        ],
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
    if (isFirstRun) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      Navigator.of(context).pop();
    }
  }
}
