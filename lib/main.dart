import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/config/env_config.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa suporte a locale pt_BR do pacote intl
  await initializeDateFormatting('pt_BR', null);

  // Inicializa leitura das variáveis de ambiente (.env)
  await EnvConfig.initialize();

  // Inicializa Firebase com credenciais reais
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Inicializa serviço de Notificações (FCM + Notificações Locais)
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase / Notificações: $e');
  }

  // Inicializa armazenamento local persistente
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FatecAnnouncementsApp(),
    ),
  );
}
