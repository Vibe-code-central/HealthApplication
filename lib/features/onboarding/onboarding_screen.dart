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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || double.tryParse(val) == null ? 'Valid weight required.' : null,
                    onSaved: (val) => _weight = double.parse(val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'HEIGHT (CM)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: RequiemColors.secondarySurface,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || double.tryParse(val) == null ? 'Valid height required.' : null,
                    onSaved: (val) => _height = double.parse(val!),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CONFIRM PROFILE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
