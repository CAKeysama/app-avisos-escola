/// Validadores de formulários e regras de negócio de entrada.
class Validators {
  Validators._();

  static String? required(String? value, [String message = 'Campo obrigatório']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o e-mail';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? customMessage]) {
    if (value == null || value.trim().length < min) {
      return customMessage ?? 'Mínimo de $min caracteres';
    }
    return null;
  }
}
