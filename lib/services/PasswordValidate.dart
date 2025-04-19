String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter password'; // Сообщение, если поле пустое
  }

  // Регулярное выражение для проверки пароля
  RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  if (!regex.hasMatch(value)) {
    return 'Enter valid password'; // Сообщение, если пароль не соответствует требованиям
  }

  return null; // Возвращаем null, если пароль валиден
}

bool comparePasswords(String firstPass, String secondPass) {
  if (firstPass == secondPass) {
    return true;
  }
  return false;
}
