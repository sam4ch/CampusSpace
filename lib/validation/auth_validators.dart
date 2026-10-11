abstract final class AuthValidators {
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Введите почту';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Введите корректный e-mail';
    }
    return null;
  }

  static String? password(String? value) => (value?.length ?? 0) < 6
      ? 'Пароль должен содержать минимум 6 символов'
      : null;

  static String? name(String? value) =>
      value == null || value.trim().isEmpty ? 'Введите имя' : null;
}
