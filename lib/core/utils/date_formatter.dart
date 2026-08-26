import 'package:intl/intl.dart';

/// Utilitário para formatação amigável de datas e prazos.
class DateFormatter {
  DateFormatter._();

  static DateFormat get _fullDate {
    try {
      return DateFormat("dd 'de' MMMM 'de' yyyy", 'pt_BR');
    } catch (_) {
      return DateFormat("dd/MM/yyyy");
    }
  }

  static DateFormat get _shortDate {
    try {
      return DateFormat('dd/MM/yyyy', 'pt_BR');
    } catch (_) {
      return DateFormat('dd/MM/yyyy');
    }
  }

  static DateFormat get _timeOnly {
    try {
      return DateFormat('HH:mm', 'pt_BR');
    } catch (_) {
      return DateFormat('HH:mm');
    }
  }

  static DateFormat get _dateTime {
    try {
      return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    } catch (_) {
      return DateFormat('dd/MM/yyyy HH:mm');
    }
  }

  /// Formata data completa (ex: 26 de Agosto de 2026)
  static String formatFull(DateTime date) => _fullDate.format(date);

  /// Formata data curta (ex: 26/08/2026)
  static String formatShort(DateTime date) => _shortDate.format(date);

  /// Formata hora (ex: 14:30)
  static String formatTime(DateTime date) => _timeOnly.format(date);

  /// Formata data e hora
  static String formatDateTime(DateTime date) => _dateTime.format(date);

  /// Formata de maneira relativa e humanizada (ex: "Agora há pouco", "Há 2 horas", "Ontem às 14:00")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      // Data no futuro (ex: expiração)
      final inDays = difference.abs().inDays;
      if (inDays == 0) return 'Hoje às ${_timeOnly.format(date)}';
      if (inDays == 1) return 'Amanhã às ${_timeOnly.format(date)}';
      return 'Em $inDays dias';
    }

    if (difference.inSeconds < 60) {
      return 'Agora há pouco';
    } else if (difference.inMinutes < 60) {
      final min = difference.inMinutes;
      return 'Há $min ${min == 1 ? 'minuto' : 'minutos'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Há $hours ${hours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inDays == 1) {
      return 'Ontem às ${_timeOnly.format(date)}';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return _shortDate.format(date);
    }
  }
}
