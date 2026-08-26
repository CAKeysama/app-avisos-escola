import 'package:flutter/services.dart';

/// Gerenciador centralizado e tipado de variáveis de ambiente.
/// Permite carregar chaves do arquivo `.env` e de `--dart-define`.
class EnvConfig {
  EnvConfig._();

  static final Map<String, String> _envMap = {};

  /// Carrega o arquivo `.env` dos assets da aplicação de forma assíncrona.
  static Future<void> initialize() async {
    try {
      final content = await rootBundle.loadString('.env');
      final lines = content.split('\n');

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;

        final separatorIndex = line.indexOf('=');
        if (separatorIndex != -1) {
          final key = line.substring(0, separatorIndex).trim();
          var value = line.substring(separatorIndex + 1).trim();

          // Remove aspas simples ou duplas envolventes
          if ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'"))) {
            value = value.substring(1, value.length - 1);
          }

          _envMap[key] = value;
        }
      }
    } catch (_) {
      // Se o arquivo .env não for encontrado nos assets, continua com valores padrão
    }
  }

  /// Retorna o valor de uma variável com fallback
  static String get(String key, {String defaultValue = ''}) {
    return _envMap[key] ?? defaultValue;
  }

  // Getters tipados
  static String get appEnv => get('APP_ENV', defaultValue: 'development');
  static String get appName => get('APP_NAME', defaultValue: 'Avisos Acadêmicos FATEC');
  static String get appVersion => get('APP_VERSION', defaultValue: '1.0.0');

  static String get institutionName => get('INSTITUTION_NAME', defaultValue: 'FATEC');
  static String get institutionUnit => get('INSTITUTION_UNIT', defaultValue: 'Unidade Central');
  static String get institutionSupportEmail => get('INSTITUTION_SUPPORT_EMAIL', defaultValue: 'suporte@fatec.edu.br');

  static String get firebaseApiKey => get('FIREBASE_API_KEY');
  static String get firebaseAppId => get('FIREBASE_APP_ID');
  static String get firebaseMessagingSenderId => get('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseProjectId => get('FIREBASE_PROJECT_ID', defaultValue: 'app-sala-avisos-fatec');
  static String get firebaseStorageBucket => get('FIREBASE_STORAGE_BUCKET');
  static String get firebaseAuthDomain => get('FIREBASE_AUTH_DOMAIN');

  static String get fcmDefaultTopic => get('FCM_DEFAULT_TOPIC', defaultValue: 'school_all');

  static bool get enableMockData => get('ENABLE_MOCK_DATA', defaultValue: 'true').toLowerCase() == 'true';
  static bool get enableAnalytics => get('ENABLE_ANALYTICS', defaultValue: 'false').toLowerCase() == 'true';
  static bool get enableCrashlytics => get('ENABLE_CRASHLYTICS', defaultValue: 'false').toLowerCase() == 'true';

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}
