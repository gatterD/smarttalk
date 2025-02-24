String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Имя пользователя не может быть пустым';
  }

  // Проверка на минимальную и максимальную длину
  if (value.length < 3) {
    return 'Имя пользователя должно содержать не менее 3 символов';
  }

  if (value.length > 20) {
    return 'Имя пользователя должно содержать не более 20 символов';
  }

  // Проверка на допустимые символы (буквы, цифры, подчеркивания)
  final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
  if (!validCharacters.hasMatch(value)) {
    return 'Имя пользователя может содержать только буквы, цифры и подчеркивания';
  }

  return null; // Возвращаем null, если валидация прошла успешно
}
