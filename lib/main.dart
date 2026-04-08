import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/theme.dart';
import 'core/storage/hive_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register adapters and open boxes
  await HiveSetup.init();
  
  runApp(
    const ProviderScope(
      child: RequiemApp(),
    ),
  );
}

class RequiemApp extends ConsumerWidget {
  const RequiemApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Project Requiem',
      theme: RequiemTheme.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Text('REQUIEM M.V.P. INITIALIZED'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
