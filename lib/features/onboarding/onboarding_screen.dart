import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../providers/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _weight = 0;
  double _height = 0;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref.read(userProvider.notifier).createProfile(_name, _height, _weight);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: RequiemColors.primaryBackground,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'PROJECT REQUIEM',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: RequiemColors.bsaaRed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'INITIATE DOSSIER',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: RequiemColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'OPERATIVE ALIAS',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: RequiemColors.secondarySurface,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (val) => val == null || val.isEmpty ? 'Alias required.' : null,
                    onSaved: (val) => _name = val ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'STARTING WEIGHT (KG)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: RequiemColors.secondarySurface,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Weight required.';
                      final parsed = double.tryParse(val);
                      if (parsed == null || parsed <= 0) return 'Enter a valid weight (e.g. 85).';
                      return null;
                    },
                    onSaved: (val) => _weight = double.tryParse(val ?? '') ?? 85.0,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'HEIGHT (CM)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: RequiemColors.secondarySurface,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Height required.';
                      final parsed = double.tryParse(val);
                      if (parsed == null || parsed <= 0) return 'Enter a valid height (e.g. 170).';
                      return null;
                    },
                    onSaved: (val) => _height = double.tryParse(val ?? '') ?? 170.0,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CONFIRM PROFILE'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
