/// Constantes globais do sistema.
class AppConstants {
  AppConstants._();

  // Nome do aplicativo
  static const String appName = 'Mural FATEC';
  static const String appSubtitle = 'Avisos Acadêmicos Oficiais';

  // Nomes de coleções no Firestore
  static const String collectionUsers = 'users';
  static const String collectionAnnouncements = 'announcements';
  static const String collectionCourses = 'courses';
  static const String collectionClasses = 'classes';
  static const String collectionReads = 'announcement_reads';

  // Chaves de SharedPreferences
  static const String keyThemeMode = 'theme_mode';
  static const String keyAuthToken = 'auth_token';
  static const String keyLastSync = 'last_sync_timestamp';

  // Tópicos do Firebase Cloud Messaging
  static const String topicSchoolAll = 'school_all';
  static String topicCourse(String courseId) => 'course_$courseId';
  static String topicClass(String classId) => 'class_$classId';
}
