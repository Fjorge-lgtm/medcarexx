import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/notification_service.dart';
import 'core/auth_service.dart';
import 'data/datasources/isar_service.dart';
import 'presentation/views/login_view.dart';
import 'presentation/views/register_view.dart';
import 'presentation/providers/medicine_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barra de status transparente para o gradiente aparecer
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final notificationService = NotificationService();
  await notificationService.init();

  final isarService = IsarService();
  await isarService.init();

  final authService = AuthService();
  final hasPin = await authService.hasPin();
  final user   = await isarService.getUser();

  runApp(
    ProviderScope(
      overrides: [
        isarServiceProvider.overrideWithValue(isarService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: MyApp(startWithLogin: hasPin && user != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool startWithLogin;
  const MyApp({super.key, required this.startWithLogin});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: startWithLogin ? const LoginView() : const RegisterView(),
    );
  }
}
