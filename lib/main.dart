import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/config/env_config.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa suporte a locale pt_BR do pacote intl
  await initializeDateFormatting('pt_BR', null);

  // Inicializa leitura das variáveis de ambiente (.env)
  await EnvConfig.initialize();

  // Inicializa armazenamento local persistente (SharedPreferences)
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
